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
#include <atomic>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <Preferences.h>

#include "calibration_logic.h"
#include "gesture_logic.h"

constexpr int FLEX_PIN = 3;
constexpr int CONTACT_PIN = 4;
constexpr int VALID_LED_PIN = 6;
constexpr int INCOMPLETE_LED_PIN = 7;
constexpr int BUZZER_PIN = 5;
constexpr bool ENABLE_BUZZER = false;
constexpr bool ACTIVE_BUZZER = false;

constexpr int ADC_MAX = kAdcMax;
constexpr int ENTER_THRESHOLD = 2457; // 60 % normalizado
constexpr int EXIT_THRESHOLD = 1433;  // 35 % normalizado
constexpr int FILTER_SAMPLES = 5;
constexpr int CALIBRATION_SAMPLES = 50;
constexpr int SATURATION_MARGIN = 4;
constexpr int SATURATION_SAMPLES = 25;
constexpr uint32_t SAMPLE_MS = 20;
constexpr uint32_t TELEMETRY_MS = 250;
constexpr uint32_t ATTEMPT_TIMEOUT_MS = 5000;
constexpr uint32_t LED_PULSE_MS = 400;

constexpr char DEVICE_NAME[] = "HandSense";
constexpr char SERVICE_UUID[] = "6c7a0001-8e2d-4f91-a6b5-3d3f7a120001";
constexpr char EVENTS_UUID[] = "6c7a0002-8e2d-4f91-a6b5-3d3f7a120001";
constexpr char CONTROL_UUID[] = "6c7a0003-8e2d-4f91-a6b5-3d3f7a120001";

Preferences preferences;
CalibrationSet calibration{{0, 0}, {0, 0}};
bool calibrationFromMemory = false;
bool calibrationBlocked = false;
int pendingRestFlex = -1;
int pendingRestContact = -1;
int pendingRestFlexMin = ADC_MAX;
int pendingRestFlexMax = 0;
int pendingRestContactMin = ADC_MAX;
int pendingRestContactMax = 0;

enum class CaptureKind { NONE, REST, PINCH };
struct CalibrationCapture {
  CaptureKind kind = CaptureKind::NONE;
  int count = 0;
  int64_t flexSum = 0;
  int64_t contactSum = 0;
  int flexMin = ADC_MAX;
  int flexMax = 0;
  int contactMin = ADC_MAX;
  int contactMax = 0;
};
CalibrationCapture capture;

GestureDetector detector(ENTER_THRESHOLD, EXIT_THRESHOLD, ENTER_THRESHOLD,
                         EXIT_THRESHOLD, ATTEMPT_TIMEOUT_MS);
FlexOnlyCounter flexOnlyCounter(ENTER_THRESHOLD, EXIT_THRESHOLD);

BLEServer *bleServer = nullptr;
BLECharacteristic *eventsCharacteristic = nullptr;
std::atomic<bool> bleConnected{false};
std::atomic<bool> resetRequested{false};
std::atomic<bool> pingRequested{false};
std::atomic<bool> badCommandRequested{false};
bool wasBleConnected = false;
uint32_t eventSequence = 0;

int flexBuffer[FILTER_SAMPLES] = {};
int contactBuffer[FILTER_SAMPLES] = {};
int bufferIndex = 0;
int filterCount = 0;
long flexSum = 0;
long contactSum = 0;
int flexSaturationCount = 0;
int contactSaturationCount = 0;
uint32_t lastSample = 0;
uint32_t lastTelemetry = 0;
uint32_t validLedUntil = 0;
uint32_t incompleteLedUntil = 0;
uint32_t buzzerUntil = 0;
bool buzzerOn = false;

void resetSession() {
  detector = GestureDetector(ENTER_THRESHOLD, EXIT_THRESHOLD, ENTER_THRESHOLD,
                             EXIT_THRESHOLD, ATTEMPT_TIMEOUT_MS);
  flexOnlyCounter = FlexOnlyCounter(ENTER_THRESHOLD, EXIT_THRESHOLD);
  eventSequence = 0;
  validLedUntil = incompleteLedUntil = millis();
  digitalWrite(VALID_LED_PIN, LOW);
  digitalWrite(INCOMPLETE_LED_PIN, LOW);
  if (ENABLE_BUZZER && buzzerOn) {
    if (!ACTIVE_BUZZER) noTone(BUZZER_PIN);
    digitalWrite(BUZZER_PIN, LOW);
    buzzerOn = false;
  }
  flexSum = contactSum = 0;
  bufferIndex = 0;
  filterCount = 0;
  flexSaturationCount = contactSaturationCount = 0;
  for (int i = 0; i < FILTER_SAMPLES; ++i) {
    flexBuffer[i] = 0;
    contactBuffer[i] = 0;
  }
}

void notifyText(const String &message) {
  if (!bleConnected || eventsCharacteristic == nullptr)
    return;
  eventsCharacteristic->setValue(message.c_str());
  eventsCharacteristic->notify();
  Serial.print("BLE TX: ");
  Serial.println(message);
}

const char *eventCode(GestureEvent event) {
  switch (event) {
  case GestureEvent::COMPLETA:
    return "C";
  case GestureEvent::SIN_CONTACTO:
    return "NC";
  case GestureEvent::SIN_FLEXION:
    return "NF";
  case GestureEvent::SIN_LIBERACION:
    return "NR";
  case GestureEvent::NINGUNO:
    return nullptr;
  }
  return nullptr;
}

char stateCode(GestureState state) {
  switch (state) {
  case GestureState::REPOSO:
    return 'R';
  case GestureState::FLEXION:
    return 'F';
  case GestureState::CONTACTO:
    return 'C';
  case GestureState::LIBERACION:
    return 'L';
  case GestureState::ESPERA_REPOSO:
    return 'W';
  }
  return 'U';
}

void notifyEvent(GestureEvent event) {
  const char *code = eventCode(event);
  if (code == nullptr)
    return;
  notifyText("HS1,E," + String(++eventSequence) + "," + code);
}

void notifyTelemetry(int flex, int contact, GestureState state) {
  const int flexPercent =
      (static_cast<long>(flex) * 100 + ADC_MAX / 2) / ADC_MAX;
  const int contactPercent =
      (static_cast<long>(contact) * 100 + ADC_MAX / 2) / ADC_MAX;
  notifyText("HS1,T," + String(flexPercent) + "," + String(contactPercent) +
             "," + stateCode(state));
}

void notifyUncalibratedTelemetry(int flex, int contact) {
  const int flexPercent =
      (static_cast<long>(flex) * 100 + ADC_MAX / 2) / ADC_MAX;
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
    resetRequested = false;
    pingRequested = false;
    badCommandRequested = false;
    Serial.println("BLE desconectado");
  }
};

class HandSenseControlCallbacks final : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *characteristic) override {
    const String command = characteristic->getValue();
    Serial.print("BLE RX: ");
    Serial.println(command);
    if (command == "HS1,C,PING") {
      pingRequested = true;
    } else if (command == "HS1,C,RESET") {
      resetRequested = true;
      // Confirmar solo después de ejecutar RESET en loop().
    } else {
      badCommandRequested = true;
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

bool readCalibration(CalibrationSet &value) {
  if (!preferences.begin("handsense", true))
    return false;
  const bool complete =
      preferences.getUChar("version", 0) == 1 && preferences.isKey("fRest") &&
      preferences.isKey("fPinch") && preferences.isKey("cRest") &&
      preferences.isKey("cPinch") && preferences.isKey("checksum");
  if (complete) {
    value = {
        {preferences.getInt("fRest", -1), preferences.getInt("fPinch", -1)},
        {preferences.getInt("cRest", -1), preferences.getInt("cPinch", -1)}};
  }
  const uint32_t storedChecksum = preferences.getUInt("checksum", 0);
  preferences.end();
  return complete && calibrationValid(value) &&
         storedChecksum == calibrationChecksum(value);
}

void loadCalibration() {
  CalibrationSet stored;
  calibrationFromMemory = readCalibration(stored);
  if (calibrationFromMemory)
    calibration = stored;
}

bool saveCalibration(const CalibrationSet &candidate) {
  if (!calibrationValid(candidate) || !preferences.begin("handsense", false))
    return false;
  bool written = preferences.putUChar("version", 1) == sizeof(uint8_t);
  written =
      preferences.putInt("fRest", candidate.flex.rest) == sizeof(int32_t) &&
      written;
  written =
      preferences.putInt("fPinch", candidate.flex.pinch) == sizeof(int32_t) &&
      written;
  written =
      preferences.putInt("cRest", candidate.contact.rest) == sizeof(int32_t) &&
      written;
  written = preferences.putInt("cPinch", candidate.contact.pinch) ==
                sizeof(int32_t) &&
            written;
  written = preferences.putUInt("checksum", calibrationChecksum(candidate)) ==
                sizeof(uint32_t) &&
            written;
  preferences.end();
  CalibrationSet verified;
  if (!written || !readCalibration(verified) ||
      !calibrationEqual(verified, candidate))
    return false;
  calibration = verified;
  calibrationFromMemory = true;
  calibrationBlocked = false;
  return true;
}

void printCalibration() {
  Serial.printf("CAL %s flex[%d,%d] contacto[%d,%d]\n",
                calibrationBlocked ? "BLOQUEADA" :
                    (calibrationFromMemory ? "MEMORIA" : "PROVISIONAL"),
                calibration.flex.rest, calibration.flex.pinch,
                calibration.contact.rest, calibration.contact.pinch);
}

void beginCapture(CaptureKind kind) {
  calibrationBlocked = true;
  capture = CalibrationCapture{};
  capture.kind = kind;
  if (kind == CaptureKind::REST) pendingRestFlex = pendingRestContact = -1;
  resetSession();
  Serial.println(kind == CaptureKind::REST
                     ? "CAL: mantén reposo mientras se toman muestras."
                     : "CAL: mantén la pinza mientras se toman muestras.");
}

void handleSerialCommand(char command) {
  if (command == 'r') {
    beginCapture(CaptureKind::REST);
  } else if (command == 'p') {
    if (pendingRestFlex < 0 || capture.kind != CaptureKind::NONE) {
      Serial.println("CAL ERROR: primero envia r.");
      return;
    }
    beginCapture(CaptureKind::PINCH);
  } else if (command == 'v') {
    printCalibration();
  } else if (command == 'b') {
    const bool opened = preferences.begin("handsense", false);
    const bool cleared = opened && preferences.clear();
    if (opened)
      preferences.end();
    calibration = {{0, 0}, {0, 0}};
    calibrationFromMemory = false;
    calibrationBlocked = true;
    pendingRestFlex = pendingRestContact = -1;
    capture = CalibrationCapture{};
    resetSession();
    Serial.println(cleared ? "Calibracion borrada."
                           : "CAL ERROR: no se pudo borrar NVS.");
  }
}

void updateCalibrationCapture(int rawFlex, int rawContact) {
  if (capture.kind == CaptureKind::NONE)
    return;
  capture.flexSum += rawFlex;
  capture.contactSum += rawContact;
  capture.flexMin = min(capture.flexMin, rawFlex);
  capture.flexMax = max(capture.flexMax, rawFlex);
  capture.contactMin = min(capture.contactMin, rawContact);
  capture.contactMax = max(capture.contactMax, rawContact);
  if (++capture.count < CALIBRATION_SAMPLES)
    return;

  const int flexAverage = capture.flexSum / capture.count;
  const int contactAverage = capture.contactSum / capture.count;
  if (capture.kind == CaptureKind::REST) {
    pendingRestFlex = flexAverage;
    pendingRestContact = contactAverage;
    pendingRestFlexMin = capture.flexMin;
    pendingRestFlexMax = capture.flexMax;
    pendingRestContactMin = capture.contactMin;
    pendingRestContactMax = capture.contactMax;
    Serial.println("Reposo registrado. Haz una pinza y envia p.");
  } else {
    const CalibrationSet candidate{{pendingRestFlex, flexAverage},
                                   {pendingRestContact, contactAverage}};
    const bool stable =
        calibrationValid(candidate) &&
        pendingRestFlexMin > SATURATION_MARGIN &&
        capture.flexMin > SATURATION_MARGIN &&
        pendingRestFlexMax < ADC_MAX - SATURATION_MARGIN &&
        capture.flexMax < ADC_MAX - SATURATION_MARGIN &&
        pendingRestContactMax < ADC_MAX - SATURATION_MARGIN &&
        capture.contactMax < ADC_MAX - SATURATION_MARGIN &&
        capture.contactMin > SATURATION_MARGIN &&
        captureStable(pendingRestFlexMin, pendingRestFlexMax,
                      absoluteSpan(candidate.flex)) &&
        captureStable(capture.flexMin, capture.flexMax,
                      absoluteSpan(candidate.flex)) &&
        captureStable(pendingRestContactMin, pendingRestContactMax,
                      absoluteSpan(candidate.contact)) &&
        captureStable(capture.contactMin, capture.contactMax,
                      absoluteSpan(candidate.contact));
    if (!stable) {
      Serial.println("CAL ERROR: referencias inestables o rango insuficiente; "
                     "no se guardó. Evaluación bloqueada; repetir r y p.");
    } else if (!saveCalibration(candidate)) {
      Serial.println("CAL ERROR: NVS no confirmó la escritura; no se activó.");
    } else {
      resetSession();
      printCalibration();
    }
    pendingRestFlex = pendingRestContact = -1;
  }
  capture = CalibrationCapture{};
}

void startFeedback(bool complete, uint32_t now) {
  if (complete)
    validLedUntil = now + LED_PULSE_MS;
  else
    incompleteLedUntil = now + LED_PULSE_MS;
  if (!ENABLE_BUZZER)
    return;
  if (ACTIVE_BUZZER)
    digitalWrite(BUZZER_PIN, HIGH);
  else
    tone(BUZZER_PIN, complete ? 2000 : 400);
  buzzerOn = true;
  buzzerUntil = now + (complete ? 150 : 400);
}

void updateFeedback(uint32_t now) {
  digitalWrite(VALID_LED_PIN, (int32_t)(validLedUntil - now) > 0);
  digitalWrite(INCOMPLETE_LED_PIN, (int32_t)(incompleteLedUntil - now) > 0);
  if (buzzerOn && (int32_t)(buzzerUntil - now) <= 0) {
    if (ACTIVE_BUZZER)
      digitalWrite(BUZZER_PIN, LOW);
    else
      noTone(BUZZER_PIN);
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
  digitalWrite(VALID_LED_PIN, LOW);
  digitalWrite(INCOMPLETE_LED_PIN, LOW);
  digitalWrite(BUZZER_PIN, LOW);
  loadCalibration();
  setupBle();
  Serial.println("HandSense XIAO integrado");
  Serial.println("Comandos serie: r=reposo p=pinza v=ver b=borrar");
  printCalibration();
}

void loop() {
  while (Serial.available())
    handleSerialCommand(Serial.read());
  const uint32_t now = millis();
  updateFeedback(now);

  if (resetRequested.exchange(false)) {
    resetSession();
    notifyText("HS1,A,RESET,OK");
    // Separar la notificación ACK de la siguiente telemetría.
    lastSample = now;
    lastTelemetry = now;
    return;
  }
  if (pingRequested.exchange(false)) {
    notifyText("HS1,A,PING,OK");
    return;
  }
  if (badCommandRequested.exchange(false)) {
    notifyText("HS1,A,CMD,ERR");
    return;
  }
  if (!bleConnected && wasBleConnected) {
    bleServer->startAdvertising();
  }
  wasBleConnected = bleConnected;
  if (now - lastSample < SAMPLE_MS)
    return;
  lastSample = now;

  const int rawFlex = analogRead(FLEX_PIN);
  const int rawContact = analogRead(CONTACT_PIN);
  updateCalibrationCapture(rawFlex, rawContact);

  flexSum -= flexBuffer[bufferIndex];
  contactSum -= contactBuffer[bufferIndex];
  flexBuffer[bufferIndex] = calibrationFromMemory
                                ? normalizeReading(rawFlex, calibration.flex)
                                : rawFlex;
  contactBuffer[bufferIndex] =
      calibrationFromMemory ? normalizeReading(rawContact, calibration.contact)
                            : rawContact;
  flexSum += flexBuffer[bufferIndex];
  contactSum += contactBuffer[bufferIndex];
  bufferIndex = (bufferIndex + 1) % FILTER_SAMPLES;
  if (filterCount < FILTER_SAMPLES)
    ++filterCount;

  const int flex = flexSum / filterCount;
  const int contact = contactSum / filterCount;

  const bool flexAtRail = railSuspicious(rawFlex, calibration.flex, false, SATURATION_MARGIN);
  const bool contactAtRail = railSuspicious(rawContact, calibration.contact,
                                           calibrationFromMemory, SATURATION_MARGIN);
  flexSaturationCount =
      flexAtRail ? min(flexSaturationCount + 1, SATURATION_SAMPLES) : 0;
  contactSaturationCount =
      contactAtRail ? min(contactSaturationCount + 1, SATURATION_SAMPLES) : 0;
  const bool signalSuspicious = flexSaturationCount >= SATURATION_SAMPLES ||
                                contactSaturationCount >= SATURATION_SAMPLES;

  if (!calibrationFromMemory || calibrationBlocked || capture.kind != CaptureKind::NONE ||
      pendingRestFlex >= 0 || signalSuspicious || flexAtRail || contactAtRail ||
      filterCount < FILTER_SAMPLES) {
    detector.invalidateAttempt();
    flexOnlyCounter.invalidateAttempt();
    if (uint32_t(now - lastTelemetry) >= TELEMETRY_MS) {
      lastTelemetry = now;
      notifyUncalibratedTelemetry(rawFlex, rawContact);
      Serial.printf(
          "SENAL NO EVALUABLE raw_flex=%d (%lu mV) raw_contacto=%d (%lu mV) "
          "estado=%s\n",
          rawFlex, static_cast<unsigned long>(analogReadMilliVolts(FLEX_PIN)),
          rawContact,
          static_cast<unsigned long>(analogReadMilliVolts(CONTACT_PIN)),
          signalSuspicious ? "EXTREMO_SOSTENIDO" :
          ((flexAtRail || contactAtRail) ? "EXTREMO_ADC" : "CALIBRACION_O_FILTRO_PENDIENTE"));
    }
    return;
  }

  flexOnlyCounter.update(flex);
  const GestureResult result = detector.update(flex, contact, now);

  if (result.event != GestureEvent::NINGUNO) {
    startFeedback(result.event == GestureEvent::COMPLETA, now);
    notifyEvent(result.event);
  }
  if (uint32_t(now - lastTelemetry) >= TELEMETRY_MS) {
    lastTelemetry = now;
    notifyTelemetry(flex, contact, result.state);
    Serial.printf(
        "ADC raw/mV flex=%d/%lu contacto=%d/%lu\n", rawFlex,
        static_cast<unsigned long>(analogReadMilliVolts(FLEX_PIN)), rawContact,
        static_cast<unsigned long>(analogReadMilliVolts(CONTACT_PIN)));
  }
  if (result.event != GestureEvent::NINGUNO ||
      now - lastTelemetry < SAMPLE_MS) {
    Serial.printf(
        "F=%d C=%d estado=%s evento=%s fusion=%lu flex_solo=%lu inc=%lu\n",
        flex, contact, stateName(result.state), eventName(result.event),
        static_cast<unsigned long>(result.repetitions),
        static_cast<unsigned long>(flexOnlyCounter.count()),
        static_cast<unsigned long>(result.incomplete));
  }
}
