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

## Batería y accesibilidad de la placa

La documentación oficial del XIAO ESP32-C3 especifica entrada `BAT` de 3,7 V,
administración de carga integrada y corrientes nominales de 380 mA (rápida) y
40 mA (lenta). Esto **no confirma** que una celda concreta sea compatible:
antes de usarla hay que identificar LiPo 1S, tensión, capacidad, protección,
polaridad y corriente máxima de carga admitida por su fabricante.

- Los pads inferiores `BAT+` y `BAT-` se identificarán por la serigrafía/plano
  oficial y se comprobarán con multímetro antes de soldar. No deducir polaridad
  por el color de un conector.
- Con placa y batería desconectadas, soldar cables cortos aislados a los pads y
  terminarlos en un conector desmontable polarizado. Añadir alivio de tensión.
  **Nunca soldar directamente sobre la celda LiPo.**
- Mantener accesibles USB-C, BOOT, RESET y el conector de antena; no cubrir ni
  doblar la antena y evitar metal encima o inmediatamente debajo de ella.
- Las primeras pruebas se hacen por USB-C de datos y con la batería físicamente
  desconectada. El montaje no se cierra hasta completar las pruebas.
- El XIAO ESP32-C3 no trae una señal ADC dedicada a la batería. Medirla por
  firmware exigiría un divisor externo y consumir un ADC; no se incorpora al
  prototipo actual. Usar multímetro.

Fuente primaria: [Seeed Studio, XIAO ESP32-C3 Getting Started](https://wiki.seeedstudio.com/XIAO_ESP32C3_Getting_Started/).

## Procedimiento incremental de integración

Cada etapa se ejecuta solo si la anterior deja evidencia satisfactoria.

| Etapa | Conexiones y firmware/comando | Resultado y evidencia | Condición para avanzar |
|---|---|---|---|
| 0. USB | Solo XIAO, antena y USB-C de datos; sin batería/periféricos. `lsusb`; `arduino-cli board list`. Compilar/cargar después un ejemplo mínimo de arranque serie. | Puerto detectado y mensaje estable a 115200; guardar salida y foto. | Sin reinicios ni calentamiento. |
| 1. Preparar batería | Todo sin alimentación. Soldar cables aislados `BAT+`/`BAT-` a conector polarizado; celda aún desconectada. | Continuidad correcta, sin corto y polaridad etiquetada; foto + multímetro. | Revisión cruzada de ambos integrantes. |
| 2. BLE | USB, sin sensores/batería. Cargar `firmware/ble_diagnostico`; nRF Connect: suscribir eventos y escribir `HS1,C,PING`. | Anuncio `HandSense-BLE-Lab` y `HS1,A,PING,OK`; captura nRF Connect. | Reconexión y ACK repetibles. |
| 3. ADC | Firmware integrado; conectar primero un divisor a 3V3/GND/D1, luego el otro a D2. Motor/buzzer desconectados. | ADC crudo y mV cambian coherentemente; tabla contra multímetro, sin saturación sostenida. | Polaridad, rango y divisor confirmados individualmente. |
| 4. Calibración/NVS | Serie 115200: `b`, `r` en reposo, `p` en pinza, `v`; reiniciar placa y repetir `v`. | Referencias estables, guardado confirmado y recuperación tras reinicio; log. | Sin conteos antes de calibrar ni con señal no evaluable. |
| 5. Actuadores | LED verde y ámbar, uno a uno, cada uno con 330 Ω. Buzzer solo tras identificar modelo/corriente/driver. | Pulsos correctos sin reinicio; tensión/corriente y video. | Compatibilidad eléctrica documentada. |
| 6. Integrado | Sensores + LED + firmware integrado; luego BLE y Flutter. | Cinco escenarios, eventos únicos, telemetría y PING/RESET; video y logs. | Secuencias repetibles y sin desconexiones críticas. |
| 7. Batería | Desconectar USB; verificar celda y polaridad con multímetro; conectar mediante el conector preparado. | Arranque y duración observados, sin calor/caída anormal; registro de tensión. | Alimentación estable bajo BLE y actuadores. |
| 8. Montaje final | Fijación textil, alivio de tensión, USB/BOOT/RESET/antena accesibles. | Ensayo completo y fotos finales. | Repetir prueba funcional después de vestirlo. |

Comandos preparados (no ejecutan carga mientras se omita `upload`):

```sh
lsusb | grep -Ei 'Espressif|Seeed|303a|2886'
arduino-cli board list
arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/xiao_integrado
arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/ble_diagnostico
# Solo con autorización y puerto confirmado:
arduino-cli upload -p /dev/ttyACM0 --fqbn esp32:esp32:XIAO_ESP32C3 firmware/xiao_integrado
arduino-cli monitor -p /dev/ttyACM0 --config baudrate=115200
```

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
