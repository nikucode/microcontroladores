# Montaje físico XIAO ESP32-C3 — especificación preliminar revisada

**Estado:** netlist preliminar; NO validado en Fritzing/SimulIDE ni en protoboard física. No representa un archivo .fzz terminado.

## Placa y pines
| Señal | Pin XIAO | GPIO | Estado |
|---|---|---|---|
| FLEX_ADC | D1/A1 | GPIO3 (ADC1) | previsto |
| FSR_ADC | D2/A2 | GPIO4 (ADC1) | previsto |
| LED_OK | D4 | GPIO6 | previsto |
| LED_AVISO | D5 | GPIO7 | previsto |
| MOTOR_GATE | D6/TX | GPIO21 | **reservado y condicionado**: posible conflicto UART |
| Sensores | 3V3 + GND | — | solo a 3,3 V |

**NO reutilizar** GPIO34/35 del ESP32 DevKit del Wokwi histórico.

## Redes eléctricas propuestas
```text
3V3 — R1 47kΩ — nodo FLEX_ADC — sensor flexivo — GND
                           └── XIAO D1/GPIO3

3V3 — FSR402 — nodo FSR_ADC — R2 10kΩ — GND
                         └── XIAO D2/GPIO4

XIAO D4/GPIO6 — R3 330Ω — ánodo LED verde — cátodo — GND
XIAO D5/GPIO7 — R4 330Ω — ánodo LED ámbar — cátodo — GND
```
**Orientación corregida del divisor FLEX:** cuando la resistencia del sensor aumenta, sube V_FLEX (si comportamiento y polaridad reales coinciden). Un plano previo tenía FLEX invertido: **no reutilizarlo**.

```text
Vflex = 3,3 × Rflex /(47.000 + Rflex)
Vfsr  = 3,3 × 10.000/(Rfsr + 10.000)
```
Son tensiones **ideales calculadas**, no medidas. Usar el ADC ESP32-C3 con atenuación/calibración apropiadas; comparar mV contra multímetro.

La documentación oficial confirma D1/GPIO3 y D2/GPIO4 como canales ADC1. Con Arduino-ESP32, 11 dB publica un rango medible aproximado de 150–3100 mV, no 0–3300 mV lineales. El divisor FSR ideal se acerca a 3,3 V cuando su resistencia cae, por lo que **puede saturar la lectura** aunque no exista un corto. Antes de fijar R2 o umbrales: medir el máximo, configurar `analogSetPinAttenuation(..., ADC_11db)`, comparar `analogReadMilliVolts()` con multímetro y redimensionar el divisor si supera el rango útil. Fuentes: [pinout XIAO](https://wiki.seeedstudio.com/XIAO_ESP32C3_Getting_Started/) y [ADC Arduino-ESP32](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/adc.html).

## Motor: aún NO conectar
Si es **motor suelto** compatible con driver elegido: GPIO → resistencia serie gate (100–330 Ω inicial) → gate MOSFET; gate → 100kΩ → GND; source → GND; drain → motor negativo; motor positivo → fuente **nominal adecuada**; GND común controlado; diodo de rueda libre inverso (cátodo a +motor, ánodo a drain) si corresponde. **Verificar hoja de datos, encapsulado, fuente y corriente.** No conectar directamente motor al GPIO ni dar por hecho que 3V3 puede alimentarlo. Si motor es módulo con driver, diseñar según módulo, no por duplicación.

## Estructura física y prueba
1. **Mesa:** protoboard, XIAO accesible por USB, antena sin tensión ni interferencia de soporte, sensores conectables sin flexionar sus terminales.
2. **Antes de energizar:** multímetro continuidad de rieles (pueden estar cortados), cortocircuitos 3V3/GND, polaridad LEDs, pines reales y rutas de masas.
3. **USB sin motor:** cargar diagnóstico BLE, comprobar anuncio, `HS1,C,PING` y respuesta `HS1,A,PING,OK`; no asumir BLE probado solo por compilar app.
4. **ADC:** conectar flexivo primero, FSR después; registrar reposo/activo, V medida vs lectura ADC; verificar que los valores no saturen.
5. **LED:** uno por uno con resistencias 330 Ω; confirmar que no reinicia MCU.
6. **Motor separado:** medir tensión y corriente, integrar solo con driver validado.
7. **Vestible:** sensor flexivo en funda dorsal del índice con holgura longitudinal, FSR en contacto pulgar/índice con apoyo repetible, electrónica en muñequera, cable flexible y alivio de tensión; repetir ensayos.

## Entregables físicos aún faltantes
- .fzz de Fritzing **real** con breadboard y schematic coincidentes.
- SimulIDE con resistencias variables (solo modelos analógicos, no BLE).
- Fotos de protoboard con identificación de agujeros una vez conocida la geometría real.
- Medición motor/FSR/flexivo y validación final.
