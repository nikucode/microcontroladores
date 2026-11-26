# Validación del firmware físico XIAO

Base auditada: `62616d3`. Firmware canónico: `xiao_integrado.ino` junto con
`gesture_logic.h` y `calibration_logic.h`. `logica_gesto/` permanece como
simulación histórica. No se modificó Flutter, no se abrió un puerto y no se
cargó hardware.

## Correcciones verificadas en software

- El timeout vence cuando `uint32_t(now - inicio) >= 5000`; se comprueba antes
  de aceptar liberaciones. Funciona también al desbordarse `millis()`.
- Un recontacto tras pérdida prematura de flexión no puede convertirse después
  en `COMPLETA`. Cada intento emite como máximo un resultado.
- El detector se arma solo después de observar reposo; cubre arranque, reinicio
  y recalibración con entradas activas.
- La calibración acepta polaridad ascendente y descendente, valida ADC 0..4095,
  separación mínima existente de 200 cuentas y estabilidad de las dos posturas.
- La captura de 50 muestras es incremental y no detiene el muestreo con
  `delay()`. Mientras se captura o espera la segunda postura no se clasifica.
- NVS exige versión, cuatro claves válidas y checksum. Cada escritura se
  comprueba por tamaño y relectura exacta antes de activar referencias.
- Reiniciar o calibrar limpia detector, contador, promedio y diagnóstico de
  saturación. No se guardan muestras ni contadores continuamente.
- Saturación sostenida se informa como señal no evaluable, sin atribuir causa.
  Se registran ADC crudo y milivoltios de `analogReadMilliVolts()`; no se
  presentan como grados ni newtons.
- Las salidas arrancan en LOW; buzzer continúa deshabilitado. UUID, HS1 y GPIO
  3/4/5/6/7 permanecen sin cambios.

La estabilidad se acepta cuando el recorrido pico a pico de cada captura no
supera 25 % de la separación reposo-pinza. Es una protección provisional que
debe contrastarse con datos físicos; no es una calibración clínica.

## Pruebas ejecutadas

```sh
cd ../xiao_integrado_tests
g++ -std=c++17 -Wall -Wextra -Wpedantic -Wconversion -Werror \
  -fsanitize=address,undefined test_regressions.cpp -o /tmp/handsense-xiao-tests
ASAN_OPTIONS=detect_leaks=0 /tmp/handsense-xiao-tests
```

Resultado: `14 grupos de pruebas del firmware físico aprobados`. Incluyen las
nueve secuencias históricas, las tres regresiones, resultado único,
recuperación, arranque activo, histéresis, polaridades, estabilidad, límites y
desbordamiento temporal. LeakSanitizer no funciona bajo ptrace en este entorno.
El sketch completo también pasó una comprobación sintáctica con dobles mínimos
de Arduino/BLE; esto no equivale a compilar para el microcontrolador.

## Compilación XIAO

Evidencia aportada por Alex desde su terminal normal: Arduino CLI 1.6.0, core
ESP32 3.3.12 y FQBN `esp32:esp32:XIAO_ESP32C3`.

- `firmware/ble_diagnostico`: compilación aprobada; flash 608367 B (46 %) y
  RAM estática 17804 B (5 %).
- `firmware/xiao_integrado`: compilación aprobada; flash 639493 B (48 %) y RAM
  estática 18396 B (5 %).

Esto confirma compilación objetivo, no funcionamiento físico. El XIAO aún no
se ha conectado ni flasheado. ADC, NVS, BLE, consumo y actuadores permanecen
sin validar físicamente.

## Continuidad del 24/11 — firmware y montaje

Se repitió la suite con los mismos flags estrictos y sanitizadores: `14 grupos
de pruebas del firmware físico aprobados`. Las nueve secuencias históricas y
las regresiones permanecen cubiertas. `git diff --check` no detectó errores.

Posteriormente Alex instaló Arduino CLI 1.6.0 y core ESP32 3.3.12 y compiló
ambos sketches correctamente, con los resultados registrados arriba.

Se renombró el archivo principal del diagnóstico a
`ble_diagnostico/ble_diagnostico.ino`: Arduino exige que el `.ino` principal
coincida con el nombre de su carpeta. El contenido HS1 no cambió.

`test_regressions.cpp` se trasladó a la carpeta hermana
`firmware/xiao_integrado_tests/`. Dejar un archivo con `main()` dentro de la
carpeta del sketch podía interferir con el enlazado Arduino. Los encabezados
compartidos y los 14 grupos de pruebas permanecen sin cambios funcionales.

La revisión oficial del XIAO confirma D1/GPIO3 y D2/GPIO4 como ADC1, batería
LiPo 1S de 3,7 V, cargador integrado (380 mA rápida/40 mA lenta) y ausencia de
medición de batería incorporada. La compatibilidad de la celda, su protección,
polaridad y corriente admisible siguen pendientes de identificación. El
procedimiento incremental 0–8 y los comandos de detección/carga/monitor quedaron
en `documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md`; no se cargó firmware ni
se abrió ningún puerto.
