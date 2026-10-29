#include "gesture_logic.h"

constexpr int FLEX_PIN = 34;
constexpr int CONTACT_PIN = 35;
constexpr int VALID_LED_PIN = 18;
constexpr int INCOMPLETE_LED_PIN = 19;
constexpr int ENTER_THRESHOLD = 2457;  // 60 % del ADC, solo para simulación
constexpr int EXIT_THRESHOLD = 1433;   // 35 %: histéresis contra oscilaciones
constexpr uint32_t ATTEMPT_TIMEOUT_MS = 3000;
constexpr uint32_t SAMPLE_MS = 20;
constexpr uint32_t LED_PULSE_MS = 400;
constexpr int FILTER_SAMPLES = 5;

GestureDetector detector(ENTER_THRESHOLD, EXIT_THRESHOLD, ENTER_THRESHOLD,
                         EXIT_THRESHOLD, ATTEMPT_TIMEOUT_MS);
FlexOnlyCounter flexOnlyCounter(ENTER_THRESHOLD, EXIT_THRESHOLD);
int flexBuffer[FILTER_SAMPLES] = {};
int contactBuffer[FILTER_SAMPLES] = {};
int bufferIndex = 0;
long flexSum = 0;
long contactSum = 0;
uint32_t lastSample = 0;
uint32_t validLedUntil = 0;
uint32_t incompleteLedUntil = 0;

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);
  pinMode(FLEX_PIN, INPUT);
  pinMode(CONTACT_PIN, INPUT);
  pinMode(VALID_LED_PIN, OUTPUT);
  pinMode(INCOMPLETE_LED_PIN, OUTPUT);
  Serial.println("flex_adc contacto_adc estado evento fusion flex_solo incompletas");
}

void loop() {
  const uint32_t now = millis();
  digitalWrite(VALID_LED_PIN, now < validLedUntil);
  digitalWrite(INCOMPLETE_LED_PIN, now < incompleteLedUntil);
  if (now - lastSample < SAMPLE_MS) return;
  lastSample = now;

  flexSum -= flexBuffer[bufferIndex];
  contactSum -= contactBuffer[bufferIndex];
  flexBuffer[bufferIndex] = analogRead(FLEX_PIN);
  contactBuffer[bufferIndex] = analogRead(CONTACT_PIN);
  flexSum += flexBuffer[bufferIndex];
  contactSum += contactBuffer[bufferIndex];
  bufferIndex = (bufferIndex + 1) % FILTER_SAMPLES;

  const int flex = flexSum / FILTER_SAMPLES;
  const int contact = contactSum / FILTER_SAMPLES;
  flexOnlyCounter.update(flex);
  const GestureResult result = detector.update(flex, contact, now);

  if (result.event == GestureEvent::COMPLETA)
    validLedUntil = now + LED_PULSE_MS;
  else if (result.event != GestureEvent::NINGUNO)
    incompleteLedUntil = now + LED_PULSE_MS;

  Serial.printf("%d %d %s %s %lu %lu %lu\n", flex, contact,
                stateName(result.state), eventName(result.event),
                static_cast<unsigned long>(result.repetitions),
                static_cast<unsigned long>(flexOnlyCounter.count()),
                static_cast<unsigned long>(result.incomplete));
}
