/*
 * HandSense BLE - prueba mínima de transporte
 *
 * No lee sensores ni controla actuadores. Se mantiene separado del firmware
 * de gestos para comprobar primero anuncio, suscripción y escritura GATT.
 * Compatible con placas ESP32 con BLE usando el core Arduino-ESP32.
 */

#include <Arduino.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

static const char *DEVICE_NAME = "HandSense-BLE-Lab";
static const char *SERVICE_UUID = "6c7a0001-8e2d-4f91-a6b5-3d3f7a120001";
static const char *EVENTS_UUID = "6c7a0002-8e2d-4f91-a6b5-3d3f7a120001";
static const char *CONTROL_UUID = "6c7a0003-8e2d-4f91-a6b5-3d3f7a120001";

static BLEServer *server = nullptr;
static BLECharacteristic *eventsCharacteristic = nullptr;
static volatile bool connected = false;
static bool wasConnected = false;

static void notifyText(const char *message) {
  if (!connected || eventsCharacteristic == nullptr) {
    return;
  }
  eventsCharacteristic->setValue(message);
  eventsCharacteristic->notify();
  Serial.print("BLE TX: ");
  Serial.println(message);
}

class ServerCallbacks final : public BLEServerCallbacks {
  void onConnect(BLEServer *) override {
    connected = true;
    Serial.println("Cliente BLE conectado");
  }

  void onDisconnect(BLEServer *) override {
    connected = false;
    Serial.println("Cliente BLE desconectado");
  }
};

class ControlCallbacks final : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *characteristic) override {
    const String command = characteristic->getValue();
    Serial.print("BLE RX: ");
    Serial.println(command);

    if (command == "HS1,C,PING") {
      notifyText("HS1,A,PING,OK");
    } else {
      notifyText("HS1,A,CMD,ERR");
    }
  }
};

void setup() {
  Serial.begin(115200);
  delay(300);
  Serial.println("Iniciando HandSense BLE de diagnóstico");

  BLEDevice::init(DEVICE_NAME);

  server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  BLEService *service = server->createService(SERVICE_UUID);
  eventsCharacteristic = service->createCharacteristic(
      EVENTS_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY);
  eventsCharacteristic->addDescriptor(new BLE2902());
  eventsCharacteristic->setValue("HS1,A,BOOT,OK");

  BLECharacteristic *controlCharacteristic = service->createCharacteristic(
      CONTROL_UUID,
      BLECharacteristic::PROPERTY_WRITE);
  controlCharacteristic->setCallbacks(new ControlCallbacks());

  service->start();
  BLEAdvertising *advertising = BLEDevice::getAdvertising();
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setScanResponse(true);
  BLEDevice::startAdvertising();
  Serial.println("Anunciando HandSense-BLE-Lab");
}

void loop() {
  if (!connected && wasConnected) {
    delay(300);
    server->startAdvertising();
    Serial.println("Anuncio BLE reiniciado");
  }
  wasConnected = connected;
  delay(50);
}
