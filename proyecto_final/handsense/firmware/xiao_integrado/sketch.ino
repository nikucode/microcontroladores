/*
 * HandSense integrado para Seeed Studio XIAO ESP32-C3.
 *
 * D1/GPIO3: flexivo    D2/GPIO4: FSR
 * D4/GPIO6: LED completa    D5/GPIO7: LED incompleta
 * D3/GPIO5: buzzer opcional, DESHABILITADO hasta identificar su tipo.
 *
 * BLE: eventos + telemetria relativa + PING/RESET con ACK.
 * Calibracion serie: r=reposo, p=pinza, v=ver, b=borrar.
 */

#include <Arduino.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <Preferences.h>

#include "gesture_logic.h"

constexpr int FLEX_PIN = 3;
constexpr int CONTACT_PIN = 4;
constexpr int VALID_LED_PIN = 6;
constexpr int INCOMPLETE_LED_PIN = 7;
constexpr int BUZZER_PIN = 5;
constexpr bool ENABLE_BUZZER = false;
constexpr bool ACTIVE_BUZZER = false;

constexpr int ADC_MAX = 4095;
constexpr int ENTER_THRESHOLD = 2457;  // 60 % normalizado
constexpr int EXIT_THRESHOLD = 1433;   // 35 % normalizado
constexpr int MIN_CALIBRATION_SPAN = 200;
constexpr int FILTER_SAMPLES = 5;
constexpr int CALIBRATION_SAMPLES = 50;
constexpr uint32_t SAMPLE_MS = 20;
constexpr uint32_t TELEMETRY_MS = 250;
constexpr uint32_t ATTEMPT_TIMEOUT_MS = 5000;
constexpr uint32_t LED_PULSE_MS = 400;

constexpr char DEVICE_NAME[] = "HandSense";
constexpr char SERVICE_UUID[] = "6c7a0001-8e2d-4f91-a6b5-3d3f7a120001";
constexpr char EVENTS_UUID[] = "6c7a0002-8e2d-4f91-a6b5-3d3f7a120001";
constexpr char CONTROL_UUID[] = "6c7a0003-8e2d-4f91-a6b5-3d3f7a120001";

struct ChannelCalibration {
  int rest;
  int pinch;
};

Preferences preferences;
ChannelCalibration flexCalibration{0, ADC_MAX};
ChannelCalibration contactCalibration{0, ADC_MAX};
bool calibrationFromMemory = false;
int pendingRestFlex = -1;
int pendingRestContact = -1;

GestureDetector detector(ENTER_THRESHOLD, EXIT_THRESHOLD, ENTER_THRESHOLD,
                         EXIT_THRESHOLD, ATTEMPT_TIMEOUT_MS);
FlexOnlyCounter flexOnlyCounter(ENTER_THRESHOLD, EXIT_THRESHOLD);

BLEServer *bleServer = nullptr;
BLECharacteristic *eventsCharacteristic = nullptr;
volatile bool bleConnected = false;
volatile bool resetRequested = false;
bool wasBleConnected = false;
uint32_t eventSequence = 0;

int flexBuffer[FILTER_SAMPLES] = {};
int contactBuffer[FILTER_SAMPLES] = {};
int bufferIndex = 0;
long flexSum = 0;
long contactSum = 0;
uint32_t lastSample = 0;
uint32_t lastTelemetry = 0;
uint32_t validLedUntil = 0;
uint32_t incompleteLedUntil = 0;
uint32_t buzzerUntil = 0;
bool buzzerOn = false;

int normalizeReading(int raw, const ChannelCalibration &calibration) {
  const long span = static_cast<long>(calibration.pinch) - calibration.rest;
  if (span == 0) return 0;
  long normalized =
      (static_cast<long>(raw) - calibration.rest) * ADC_MAX / span;
  return constrain(static_cast<int>(normalized), 0, ADC_MAX);
}

void resetSession() {
  detector = GestureDetector(ENTER_THRESHOLD, EXIT_THRESHOLD, ENTER_THRESHOLD,
                             EXIT_THRESHOLD, ATTEMPT_TIMEOUT_MS);
  flexOnlyCounter = FlexOnlyCounter(ENTER_THRESHOLD, EXIT_THRESHOLD);
  eventSequence = 0;
  flexSum = contactSum = 0;
  bufferIndex = 0;
  for (int i = 0; i < FILTER_SAMPLES; ++i) {
    flexBuffer[i] = 0;
    contactBuffer[i] = 0;
  }
}

void notifyText(const String &message) {
  if (!bleConnected || eventsCharacteristic == nullptr) return;
  eventsCharacteristic->setValue(message.c_str());
  eventsCharacteristic->notify();
  Serial.print("BLE TX: ");
  Serial.println(message);
}

const char *eventCode(GestureEvent event) {
  switch (event) {
    case GestureEvent::COMPLETA: return "C";
    case GestureEvent::SIN_CONTACTO: return "NC";
    case GestureEvent::SIN_FLEXION: return "NF";
    case GestureEvent::SIN_LIBERACION: return "NR";
    case GestureEvent::NINGUNO: return nullptr;
  }
  return nullptr;
}

char stateCode(GestureState state) {
  switch (state) {
    case GestureState::REPOSO: return 'R';
    case GestureState::FLEXION: return 'F';
    case GestureState::CONTACTO: return 'C';
    case GestureState::LIBERACION: return 'L';
    case GestureState::ESPERA_REPOSO: return 'W';
  }
  return 'U';
}

void notifyEvent(GestureEvent event) {
  const char *code = eventCode(event);
  if (code == nullptr) return;
  notifyText("HS1,E," + String(++eventSequence) + "," + code);
}

void notifyTelemetry(int flex, int contact, GestureState state) {
  const int flexPercent = (static_cast<long>(flex) * 100 + ADC_MAX / 2) / ADC_MAX;
  const int contactPercent =
      (static_cast<long>(contact) * 100 + ADC_MAX / 2) / ADC_MAX;
  notifyText("HS1,T," + String(flexPercent) + "," + String(contactPercent) +
             "," + stateCode(state));
}

void notifyUncalibratedTelemetry(int flex, int contact) {
  const int flexPercent = (static_cast<long>(flex) * 100 + ADC_MAX / 2) / ADC_MAX;
  const int contactPercent =
      (static_cast<long>(contact) * 100 + ADC_MAX / 2) / ADC_MAX;
  notifyText("HS1,T," + String(flexPercent) + "," + String(contactPercent) +
             ",U");
}

class HandSenseServerCallbacks final : public BLEServerCallbacks {
  void onConnect(BLEServer *) override {
    bleConnected = true;
    Serial.println("BLE conectado");
  }

  void onDisconnect(BLEServer *) override {
    bleConnected = false;
    Serial.println("BLE desconectado");
  }
};

class HandSenseControlCallbacks final : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *characteristic) override {
    const String command = characteristic->getValue();
    Serial.print("BLE RX: ");
    Serial.println(command);
    if (command == "HS1,C,PING") {
      notifyText("HS1,A,PING,OK");
    } else if (command == "HS1,C,RESET") {
      resetRequested = true;
    } else {
      notifyText("HS1,A,CMD,ERR");
    }
  }
};

void setupBle() {
  BLEDevice::init(DEVICE_NAME);
  bleServer = BLEDevice::createServer();
  bleServer->setCallbacks(new HandSenseServerCallbacks());
  BLEService *service = bleServer->createService(SERVICE_UUID);
  eventsCharacteristic = service->createCharacteristic(
      EVENTS_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  eventsCharacteristic->addDescriptor(new BLE2902());
  eventsCharacteristic->setValue("HS1,A,BOOT,OK");
  BLECharacteristic *control = service->createCharacteristic(
      CONTROL_UUID, BLECharacteristic::PROPERTY_WRITE);
  control->setCallbacks(new HandSenseControlCallbacks());
  service->start();
  BLEAdvertising *advertising = BLEDevice::getAdvertising();
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setScanResponse(true);
  BLEDevice::startAdvertising();
}

void loadCalibration() {
  preferences.begin("handsense", true);
  if (preferences.isKey("fRest")) {
    flexCalibration = {preferences.getInt("fRest", 0),
                       preferences.getInt("fPinch", ADC_MAX)};
    contactCalibration = {preferences.getInt("cRest", 0),
                          preferences.getInt("cPinch", ADC_MAX)};
    calibrationFromMemory = true;
  }
  preferences.end();
}

void saveCalibration() {
  preferences.begin("handsense", false);
  preferences.putInt("fRest", flexCalibration.rest);
  preferences.putInt("fPinch", flexCalibration.pinch);
  preferences.putInt("cRest", contactCalibration.rest);
  preferences.putInt("cPinch", contactCalibration.pinch);
  preferences.end();
  calibrationFromMemory = true;
}

void printCalibration() {
  Serial.printf("CAL %s flex[%d,%d] contacto[%d,%d]\n",
                calibrationFromMemory ? "MEMORIA" : "PROVISIONAL",
                flexCalibration.rest, flexCalibration.pinch,
                contactCalibration.rest, contactCalibration.pinch);
}

void averageRaw(int &flex, int &contact) {
  long flexTotal = 0;
  long contactTotal = 0;
  for (int i = 0; i < CALIBRATION_SAMPLES; ++i) {
    flexTotal += analogRead(FLEX_PIN);
    contactTotal += analogRead(CONTACT_PIN);
    delay(SAMPLE_MS);
  }
  flex = flexTotal / CALIBRATION_SAMPLES;
  contact = contactTotal / CALIBRATION_SAMPLES;
}

void handleSerialCommand(char command) {
  int flex;
  int contact;
  if (command == 'r') {
    averageRaw(pendingRestFlex, pendingRestContact);
    Serial.println("Reposo registrado. Haz una pinza y envia p.");
  } else if (command == 'p') {
    if (pendingRestFlex < 0) {
      Serial.println("CAL ERROR: primero envia r.");
      return;
    }
    averageRaw(flex, contact);
    if (abs(flex - pendingRestFlex) < MIN_CALIBRATION_SPAN ||
        abs(contact - pendingRestContact) < MIN_CALIBRATION_SPAN) {
      Serial.println("CAL ERROR: rango insuficiente; no se guardo.");
      return;
    }
    flexCalibration = {pendingRestFlex, flex};
    contactCalibration = {pendingRestContact, contact};
    saveCalibration();
    resetSession();
    pendingRestFlex = pendingRestContact = -1;
    printCalibration();
  } else if (command == 'v') {
    printCalibration();
  } else if (command == 'b') {
    preferences.begin("handsense", false);
    preferences.clear();
    preferences.end();
    flexCalibration = {0, ADC_MAX};
    contactCalibration = {0, ADC_MAX};
    calibrationFromMemory = false;
    resetSession();
    Serial.println("Calibracion borrada.");
  }
}

void startFeedback(bool complete, uint32_t now) {
  if (complete) validLedUntil = now + LED_PULSE_MS;
  else incompleteLedUntil = now + LED_PULSE_MS;
  if (!ENABLE_BUZZER) return;
  if (ACTIVE_BUZZER) digitalWrite(BUZZER_PIN, HIGH);
  else tone(BUZZER_PIN, complete ? 2000 : 400);
  buzzerOn = true;
  buzzerUntil = now + (complete ? 150 : 400);
}

void updateFeedback(uint32_t now) {
  digitalWrite(VALID_LED_PIN, (int32_t)(validLedUntil - now) > 0);
  digitalWrite(INCOMPLETE_LED_PIN,
               (int32_t)(incompleteLedUntil - now) > 0);
  if (buzzerOn && (int32_t)(buzzerUntil - now) <= 0) {
    if (ACTIVE_BUZZER) digitalWrite(BUZZER_PIN, LOW);
    else noTone(BUZZER_PIN);
    buzzerOn = false;
  }
}

void setup() {
  Serial.begin(115200);
  delay(500);
  analogReadResolution(12);
  analogSetPinAttenuation(FLEX_PIN, ADC_11db);
  analogSetPinAttenuation(CONTACT_PIN, ADC_11db);
  pinMode(VALID_LED_PIN, OUTPUT);
  pinMode(INCOMPLETE_LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  loadCalibration();
  setupBle();
  Serial.println("HandSense XIAO integrado");
  Serial.println("Comandos serie: r=reposo p=pinza v=ver b=borrar");
  printCalibration();
}

void loop() {
  while (Serial.available()) handleSerialCommand(Serial.read());
  const uint32_t now = millis();
  updateFeedback(now);

  if (resetRequested) {
    resetRequested = false;
    resetSession();
    notifyText("HS1,A,RESET,OK");
  }
  if (!bleConnected && wasBleConnected) {
    delay(100);
    bleServer->startAdvertising();
  }
  wasBleConnected = bleConnected;
  if (now - lastSample < SAMPLE_MS) return;
  lastSample = now;

  flexSum -= flexBuffer[bufferIndex];
  contactSum -= contactBuffer[bufferIndex];
  flexBuffer[bufferIndex] =
      normalizeReading(analogRead(FLEX_PIN), flexCalibration);
  contactBuffer[bufferIndex] =
      normalizeReading(analogRead(CONTACT_PIN), contactCalibration);
  flexSum += flexBuffer[bufferIndex];
  contactSum += contactBuffer[bufferIndex];
  bufferIndex = (bufferIndex + 1) % FILTER_SAMPLES;

  const int flex = flexSum / FILTER_SAMPLES;
  const int contact = contactSum / FILTER_SAMPLES;

  if (!calibrationFromMemory) {
    if (now - lastTelemetry >= TELEMETRY_MS) {
      lastTelemetry = now;
      notifyUncalibratedTelemetry(flex, contact);
      Serial.printf("CAL PENDIENTE raw_rel_flex=%d raw_rel_contacto=%d\n",
                    flex, contact);
    }
    return;
  }

  flexOnlyCounter.update(flex);
  const GestureResult result = detector.update(flex, contact, now);

  if (result.event != GestureEvent::NINGUNO) {
    startFeedback(result.event == GestureEvent::COMPLETA, now);
    notifyEvent(result.event);
  }
  if (now - lastTelemetry >= TELEMETRY_MS) {
    lastTelemetry = now;
    notifyTelemetry(flex, contact, result.state);
  }
  if (result.event != GestureEvent::NINGUNO || now - lastTelemetry < SAMPLE_MS) {
    Serial.printf("F=%d C=%d estado=%s evento=%s fusion=%lu flex_solo=%lu inc=%lu\n",
                  flex, contact, stateName(result.state), eventName(result.event),
                  static_cast<unsigned long>(result.repetitions),
                  static_cast<unsigned long>(flexOnlyCounter.count()),
                  static_cast<unsigned long>(result.incomplete));
  }
}
