# Procedimiento de banco — seguir en orden

## A. Preparación (sin energizar)
- Identificar el flexivo, FSR, LED y buzzer reales, medir resistencias fijas con circuito desconectado, registrar modelo/resolución del multímetro. Revisar continuidad de headers, filas y GND común. No usar modo resistencia con alimentación.
- Alimentar por USB; batería desconectada. Sensores a 3V3, nunca a 5V. No habilitar buzzer hasta conocer tipo, corriente y driver. Dos LED con 330 ohm serie por rama; confirmar si el docente acepta dos LED como dos actuadores o exige tipos distintos.
- Flexivo: 3V3 → 47 kΩ → D1/GPIO3 → flexivo → GND. FSR: 3V3 → FSR → D2/GPIO4 → 10 kΩ → GND. Estos son los divisores previstos; verificar resistencias/polaridad y tensión real antes de asumirlos. D4/GPIO6 LED verde, D5/GPIO7 LED ámbar.
- Si el FSR no responde, desconectar USB y verificar sensor aislado con ohmímetro, contacto suave sobre zona activa, continuidad del cable y del divisor. No perforar ni doblar el área activa, no concluir que está roto solo por medir resistencia muy alta en reposo. Si cambia resistencia pero no tensión, revisar circuito; si tensión cambia pero ADC no, revisar canal/atenuación/saturación. Sustituir solo por sensor de contacto apropiado si es necesario; una LDR no mide contacto de forma directa.

## B. Compilación y diagnóstico
Descomprimir el paquete en una carpeta independiente (p. ej. Descargas). Abrir terminal en la carpeta `HandSense_cierre_R3`.
```
CLI="$HOME/.local/bin/arduino-cli"
"$CLI" board list
"$CLI" compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/xiao_integrado
"$CLI" compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/calibracion_banco
"$CLI" compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/actuadores_banco
"$CLI" compile --fqbn esp32:esp32:XIAO_ESP32C3 firmware/xiao_candidato
```
Compilar no altera la placa. Si hay errores, guardar el texto y detenerse antes de cargar. Puerto ejemplo /dev/ttyACM0; usar el resultado de `board list`, no asumir que no cambió. Cerrar cualquier monitor antes de upload.

Cuando se compruebe el montaje, cargar solo el diagnóstico:
```
"$CLI" upload --fqbn esp32:esp32:XIAO_ESP32C3 --port /dev/ttyACM0 firmware/calibracion_banco
"$CLI" monitor --port /dev/ttyACM0 --config baudrate=115200
```
Si `upload` exige un binario de compilación, usar `compile --upload --fqbn ... --port ... firmware/calibracion_banco`. En el monitor: `r` reposo; `f` flexión sin contacto; `c` contacto aislado; `p` pinza; `v` resumen. Mantener cada postura estable al menos durante la captura. `t` alterna lectura viva, `x` borra capturas RAM, `h` ayuda. Registrar ADC crudo, mV, mínimo/máximo y DMM en cada postura. Capturar de nuevo si hay variación elevada.

Medir DMM en voltaje DC con punta negra en GND y roja en nodo ADC, sin causar cortos. Comparar mV con mV, no con códigos digitales. ADC C3 a 11 dB ≈0–2500 mV; si la señal se aproxima al máximo, revisar el divisor para limitar el rango útil; no forzar más presión. Si Vref≈0, registrar error absoluto, no porcentaje. `e_abs=abs(ADC_mV-DMM_mV)`; `e_pct=100*e_abs/abs(DMM_mV)` cuando aplicable. No interpretar mV como newtons/grados.

## C. Actuadores
Solo después de verificar polaridad y resistencias de los LEDs, compilar/cargar `firmware/actuadores_banco` del mismo modo y abrir monitor. `v` verde, `a` ámbar, `t` ambos, `0` apagar. Pulso máximo nominal 400 ms. El buzzer no se energiza. Si no hay luz, desconectar USB y revisar LED, resistor y pin antes de cambiar cables.

## D. Integrado candidato y calibración persistente
Si los dos sensores tienen rango distinguible y el candidato compila, cargar `firmware/xiao_candidato` (no sobreescribir código base). Desconectar la app durante calibración. Monitor 115200: `r` mantener mano relajada; esperar confirmación; `p` mantener pinza cómoda; esperar `CAL MEMORIA`; `v` registrar cuatro referencias. Si dice `BLOQUEADA`, `PROVISIONAL` o `CAL ERROR`, no seguir evaluando: corregir causa y repetir r/p. `b` elimina la calibración NVS: usar solo conscientemente, no por rutina.

Apagar/desconectar y reconectar USB; abrir monitor, `v`; comprobar mismas referencias. Verificar que reposo permite estado R, que flex y FSR cambian de manera independiente y que no se informa U. La referencia anterior podría reaparecer después de reiniciar tras una captura fallida; no usarla como prueba de éxito de la nueva captura.

## E. Ensayos (no ajustar umbrales con datos de evaluación)
Tras calibrar, realizar pinza completa lenta (reposo→flexión→contacto→liberación manteniendo flexión→reposo), flexión sin contacto, contacto sin flexión, contacto sostenido >5 s, dos pinzas consecutivas. Repetir con etiquetas independientes. Registrar contadores serial `fusion`, `flex_solo`, `inc`, estado, LED y resultado app. Para comparación real no usar solo el conteo flexivo inferido de la app. Si falla el FSR, no usar demostración como sustituto de un resultado físico. No exigir movimientos incómodos o dolorosos.

## F. App / BLE
Con el firmware integrado cargado y ambos sensores evaluables, conectar Android (no nRF Connect y Flutter simultáneamente), esperar muestra nueva. Probar PING, RESET y confirmar efecto en serial/contadores; separar comandos, verificar desconexión y reconexión. Iniciar práctica real desde reposo. Grabar capturas de modo real, respuesta de LEDs y DMM; conservar un video de respaldo y publicar en YouTube según instrucciones del informe con autorización de quienes aparezcan. Si el candidato falla, restaurar firmware base compilado y documentar qué falla, no alterar todo de urgencia.

## G. Cierre
Actualizar tablas, afiche e informe solo con resultados observados. Verificar funcionamiento continuo, stand, impresión real, código, APK, Gantt, NVS y enlace GitHub. El docente podría exigir configuración directa de registros ADC en lugar de API: explicar la equivalencia arquitectónica del ESP32 y confirmar el criterio, no afirmar que se usaron ADCON0/ADCON1.
