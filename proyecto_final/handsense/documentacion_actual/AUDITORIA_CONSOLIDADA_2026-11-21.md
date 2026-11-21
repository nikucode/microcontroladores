# Auditoría consolidada — 21/11/2026

## Estado Git y PR #2

`main` local y `origin/main` apuntaban a `f93e940` (0 commits de diferencia). Los cambios ajenos a HandSense se conservaron. `mobile/` y `firmware/ble_diagnostico/` están versionados. Se encontraron seis medios no versionados dentro de `app/` que muestran trabajos PIC anteriores y no constituyen evidencia de HandSense; no se añadieron ni eliminaron.

No fue posible consultar la ficha web del PR #2 porque la API de GitHub no respondió. Se auditaron sus dos ramas remotas locales: `docs/handsense-continuidad-2026-11-20` y `docs/handsense-auditoria-pedagogica-2026-11-20`. Ninguna es ancestro de `main`; la segunda contiene material pedagógico útil pero estados ya obsoletos sobre ausencia de Flutter/BLE. No se fusionó ninguna rama.

## Matriz ejecutiva

| Área | Estado | Evidencia | Problema | Acción prioritaria |
|---|---|---|---|---|
| Git/código móvil | Verificado | fuentes y tests en `main`; APK compilado por Alex | instalación actual no registrada | instalar APK y guardar versión/captura |
| Lógica de gesto | Verificado en C++ | 9 casos pasan | umbrales/timeout siguen siendo de simulación | medir y parametrizar en XIAO |
| Wokwi | Simulado | DevKit, GPIO34/35; dos secuencias observadas | no representa XIAO ni sensores reales | conservar como historia, no cargar al XIAO |
| BLE | Implementado sin validar | UUID coherentes, parser, diagnóstico y `PING/ACK` | sin conexión física; solo eventos, no telemetría continua | nRF Connect y luego Flutter |
| XIAO/ADC | Propuesto | D1/GPIO3 y D2/GPIO4 son ADC1 oficiales | divisor FSR puede acercarse a 3,3 V y saturar; falta calibración | medir tensión, usar atenuación y `analogReadMilliVolts` |
| Actuadores | Propuesto | dos LED y etapa conceptual de motor | motor, driver, corriente y fuente desconocidos | identificar piezas antes de energizar |
| Inventario/BOM | Pendiente | cotización y tabla provisional | modelos, cantidades recibidas y costos reales faltan | fotos/boleta/part number |
| Validación | Pendiente | CSV vacío y procedimiento | sin datos físicos, referencias ni error | ejecutar ensayos etiquetados |
| Documentación | Parcial corregido | índice, Gantt, contrato y guía | documentos históricos usan HTTP, 25/11 y “Córdova” | mantenerlos fechados, no usarlos como estado vigente |
| Tríptico | Propuesto | pauta 77×55 y contenido definido | faltan resultados y fotos reales | completar solo tras ensayos |

## Correcciones de esta auditoría

- Detector estricto: contacto primero, simultaneidad y liberación invertida ya no producen `COMPLETA`.
- Suite C++ ampliada de 5 a 9 casos antes de cambiar la lógica.
- Fuente principal actualizada con nombre **María José Córdoba**, fecha 27/11, estado Git/Flutter/BLE y ruta pedagógica.
- Se documentó el límite del ADC: 12 bits no significa medición exacta de 0–3,3 V; la lectura debe calibrarse y comprobarse con multímetro.

## Bloqueos físicos

No están confirmados inventario recibido, modelo eléctrico del motor/driver, rangos reales de sensores, montaje, BLE, telemetría, vibración ni calibración. Por ello el sistema completo sigue **pendiente de validación física**.
