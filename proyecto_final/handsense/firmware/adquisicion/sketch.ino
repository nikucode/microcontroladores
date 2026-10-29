// HandSense: primera prueba de adquisición, ESP32 clásico simulado.
// Los potenciómetros representan entradas eléctricas, no sensores físicos.
constexpr int FLEX_PIN = 34;
constexpr int CONTACT_PIN = 35;
constexpr unsigned long SAMPLE_MS = 20; // 50 muestras por segundo
unsigned long lastSample = 0;

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);
  pinMode(FLEX_PIN, INPUT);
  pinMode(CONTACT_PIN, INPUT);
  Serial.println("tiempo_ms,flex_adc,contacto_adc,flex_pct_adc,contacto_pct_adc");
}

void loop() {
  const unsigned long now = millis();
  if (now - lastSample < SAMPLE_MS) return;
  lastSample = now;
  const int flex = analogRead(FLEX_PIN);
  const int contact = analogRead(CONTACT_PIN);
  Serial.printf("%lu,%d,%d,%.2f,%.2f\n", now, flex, contact,
                flex * 100.0 / 4095.0, contact * 100.0 / 4095.0);
}
