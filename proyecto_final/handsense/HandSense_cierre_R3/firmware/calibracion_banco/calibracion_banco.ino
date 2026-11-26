/* HandSense | diagnóstico independiente de banco, 26-11-2026.
 * XIAO ESP32-C3, Arduino-ESP32 3.x. Sin BLE, NVS, conteos ni actuadores.
 * No sustituye al firmware integrado. Compilar y guardar el integrado antes
 * de cargar este sketch; restaurarlo al terminar. Usar USB, GND común, 3V3.
 */
#include <Arduino.h>
#include <stdint.h>
#include <stdlib.h>

constexpr uint8_t FLEX_PIN = 3;  // D1 / GPIO3 / ADC1
constexpr uint8_t FSR_PIN = 4;   // D2 / GPIO4 / ADC1
constexpr uint16_t N = 50;
constexpr uint32_t SAMPLE_MS = 20;
constexpr uint32_t LIVE_MS = 250;
constexpr uint16_t HIGH_RAIL = 4090;  // advertencia, no diagnóstico concluyente
constexpr uint16_t MIN_SPAN = 200;   // criterio inicial del proyecto, no clínico

struct Stats {
  uint32_t rawSum = 0, mvSum = 0;
  uint16_t low = 4095, high = 0, highRail = 0, count = 0;
  void add(uint16_t raw, uint32_t mv) {
    rawSum += raw; mvSum += mv; ++count;
    if (raw < low) low = raw;
    if (raw > high) high = raw;
    if (raw >= HIGH_RAIL) ++highRail;
  }
  double rawMean() const { return count ? double(rawSum) / count : 0; }
  double mvMean() const { return count ? double(mvSum) / count : 0; }
};
struct Capture { Stats flex, fsr; bool valid = false; };
Capture refs[4];
const char *labels[] = {"REPOSO", "FLEXION_SIN_CONTACTO", "CONTACTO_AISLADO", "PINZA"};
bool live = true;
uint32_t lastLive = 0;

void readPair(Stats &f, Stats &c) {
  // Descartar primera lectura después del cambio de canal; la lectura mV es
  // una conversión separada de la cruda, no la conversión de esa misma muestra.
  (void)analogRead(FLEX_PIN);
  uint16_t fr = analogRead(FLEX_PIN);
  uint32_t fm = analogReadMilliVolts(FLEX_PIN);
  (void)analogRead(FSR_PIN);
  uint16_t cr = analogRead(FSR_PIN);
  uint32_t cm = analogReadMilliVolts(FSR_PIN);
  f.add(fr, fm); c.add(cr, cm);
}
void printStats(const char *state, const char *sensor, const Stats &s) {
  Serial.printf("CAP,%s,%s,%u,%.2f,%u,%u,%.2f,%u\n",state,sensor,
    (unsigned)s.count,s.rawMean(),(unsigned)s.low,(unsigned)s.high,
    s.mvMean(),(unsigned)s.highRail);
}
void capture(uint8_t i) {
  Capture sample;
  Serial.printf("# Capturando %s durante ~1 s; mantener posicion estable.\n",labels[i]);
  for (uint16_t j=0;j<N;++j) {
    readPair(sample.flex, sample.fsr);
    delay(SAMPLE_MS);
  }
  sample.valid = true; refs[i] = sample;
  printStats(labels[i],"FLEX",sample.flex);
  printStats(labels[i],"FSR",sample.fsr);
  if(sample.flex.highRail || sample.fsr.highRail)
    Serial.println("# AVISO: muestras cerca del tope digital; comparar mV con multimetro.");
}
void compare(const char *name, const Stats &a, const Stats &b) {
  double delta = b.rawMean()-a.rawMean();
  double magnitude = delta < 0 ? -delta : delta;
  bool separated = a.high < b.low || b.high < a.low;
  Serial.printf("CHECK,%s,delta_raw=%.2f,span_min=%u,rangos_separados=%s,tope_activo=%u/%u\n",
    name,delta,(unsigned)MIN_SPAN,separated?"SI":"NO",(unsigned)b.highRail,(unsigned)b.count);
  if(magnitude<MIN_SPAN || !separated || b.highRail==b.count)
    Serial.println("# REVISAR antes de calibrar: variacion insuficiente, rangos solapados o tope sostenido.");
  else Serial.println("# Referencias candidatas: repetir captura y contrastar con multimetro.");
}
void report() {
  for(uint8_t i=0;i<4;++i) if(refs[i].valid) {
    printStats(labels[i],"FLEX",refs[i].flex); printStats(labels[i],"FSR",refs[i].fsr);
  }
  if(refs[0].valid && refs[1].valid) compare("FLEX_REPOSO_VS_FLEXION",refs[0].flex,refs[1].flex);
  if(refs[0].valid && refs[2].valid) compare("FSR_REPOSO_VS_CONTACTO",refs[0].fsr,refs[2].fsr);
  if(refs[0].valid && refs[3].valid) {
    compare("FLEX_REPOSO_VS_PINZA",refs[0].flex,refs[3].flex);
    compare("FSR_REPOSO_VS_PINZA",refs[0].fsr,refs[3].fsr);
  }
  Serial.println("# No se ha guardado calibracion. No se ha validado fuerza ni angulo.");
}
void help() {
  Serial.println("# r=reposo; f=flexion sin contacto; c=contacto aislado; p=pinza; v=resumen; t=alternar vivo; x=borrar capturas RAM; h=ayuda");
  Serial.println("# LIVE,t_ms,flex_raw,flex_mV,fsr_raw,fsr_mV");
  Serial.println("# CAP,estado,sensor,n,raw_prom,raw_min,raw_max,mV_prom,n_tope");
}
void setup() {
  Serial.begin(115200);
  pinMode(FLEX_PIN,INPUT); pinMode(FSR_PIN,INPUT);
  analogReadResolution(12);
  analogSetPinAttenuation(FLEX_PIN, ADC_11db);
  analogSetPinAttenuation(FSR_PIN, ADC_11db);
  delay(300);
  Serial.println("# HandSense CAL BANCO | ADC1 12 bits | sin BLE ni NVS");
  help();
}
void loop() {
  while(Serial.available()) {
    char cmd = char(Serial.read());
    switch(cmd) {
      case 'r': capture(0); break;
      case 'f': capture(1); break;
      case 'c': capture(2); break;
      case 'p': capture(3); break;
      case 'v': report(); break;
      case 't': live = !live; Serial.println(live?"# LIVE ON":"# LIVE OFF"); break;
      case 'x': for(auto &ref: refs) ref = Capture{}; Serial.println("# RAM limpia"); break;
      case 'h': help(); break;
      case '\r': case '\n': case ' ': break;
      default: Serial.println("# Comando no reconocido. h=ayuda"); break;
    }
  }
  uint32_t now = millis();
  if(live && uint32_t(now-lastLive)>=LIVE_MS) {
    lastLive=now; Stats f,c; readPair(f,c);
    Serial.printf("LIVE,%lu,%u,%lu,%u,%lu\n",(unsigned long)now,
      (unsigned)f.low,(unsigned long)f.mvSum,(unsigned)c.low,(unsigned long)c.mvSum);
  }
  delay(2);
}
