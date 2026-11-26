// HandSense: prueba independiente de los dos LEDs. Sin BLE/NVS/buzzer.
// XIAO ESP32-C3 D4/GPIO6 y D5/GPIO7, resistencia serie 330 ohm por LED.
#include <Arduino.h>
constexpr int GREEN = 6, AMBER = 7;
constexpr uint32_t PULSE_MS = 400;
uint32_t started = 0;
bool pulsing = false;
void allOff() {
  digitalWrite(GREEN, LOW); digitalWrite(AMBER, LOW); pulsing = false;
}
void pulse(bool green, bool amber) {
  allOff(); digitalWrite(GREEN, green ? HIGH : LOW);
  digitalWrite(AMBER, amber ? HIGH : LOW);
  started = millis(); pulsing = true;
  Serial.printf("LED verde=%d ambar=%d; pulso 400 ms\n",green,amber);
}
void setup() {
  pinMode(GREEN, OUTPUT); pinMode(AMBER, OUTPUT); allOff();
  Serial.begin(115200);
  Serial.println("HandSense prueba LED | v=verde, a=ambar, t=ambos, 0=apagar");
}
void loop() {
  if (pulsing && uint32_t(millis()-started) >= PULSE_MS) allOff();
  if (Serial.available()) {
    switch (Serial.read()) {
      case 'v': pulse(true,false); break;
      case 'a': pulse(false,true); break;
      case 't': pulse(true,true); break;
      case '0': allOff(); break;
      default: break;
    }
  }
}
