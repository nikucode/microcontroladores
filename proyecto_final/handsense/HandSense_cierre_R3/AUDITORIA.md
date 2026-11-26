# Auditoría de cierre — 26-11-2026
Fuente: copia local HandSense_estado_actual_26nov.tar.gz; HEAD informado 62616d3, tres commits por delante de origin/main. La copia no contiene .git ni APK. Pruebas ejecutadas aquí: g++ C++17, -Wall -Wextra -Wpedantic -Wconversion -Werror, ASan/UBSan (leak detection desactivada), 14 grupos aprobados. No hay SDK Flutter ni Arduino CLI en este entorno.

## Hallazgos y decisiones
| Prioridad | Archivo | Hallazgo | Cierre |
|---|---|---|---|
| P0 | firmware/xiao_integrado/xiao_integrado.ino loop | ADC <=4 durante 25 muestras bloquea ambos canales; FSR descargado puede ser legítimamente cero. ADC alto también puede saturar. | Medir reposo/gesto y DMM; candidato solo admite extremo bajo cerca de referencia de reposo validada; no diagnostica desconexión inequívoca. |
| P0 | mismo, updateCalibrationCapture | Referencias inválidas conservan calibración previa; el usuario podría creer que la nueva fue válida. | Confirmar CAL MEMORIA tras p; candidato bloquea evaluación tras captura fallida hasta éxito o reinicio explícito. |
| P0 | mismo, loop | Ante señal no evaluable retorna sin invalidar el intento que estaba en curso. | Candidato desarma detector y contador flexivo sin borrar totales; exigir reposo al recuperar. |
| P0 | mismo, callbacks | ACK RESET enviado antes de aplicar reset en loop; no prueba ejecución. | Candidato confirma después de reset. Conservar HS1. |
| P0 | gesture_logic.h | Secuencia estricta, activaciones simultáneas rechazadas, timeout >=5000. | 14 grupos aprobados; no cambiar política. |
| P0 | firmware | LED verde completa, ámbar incompleta; buzzer deshabilitado. | Probar ambos LED; consultar docente si dos indicadores equivalentes satisfacen dos actuadores. No activar buzzer sin modelo/corriente. |
| P0 | documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md | 150–3100 mV no corresponde al C3; motor histórico. | 0–2500 mV aprox. con 11 dB; usar mV calibrados y DMM. |
| P1 | mobile/lib/data/ble_attempt_source.dart | ACK correlacionado por nombre, no ID; timeout empieza después de escritura GATT; RESET reintenta. ACK tardío del mismo comando indistinguible. | No alterar HS1 hoy; probar comandos separados, desconexión y estado efectivo. |
| P1 | mobile/lib/ui/session_model.dart | Simulación protegida por sessionActive; real requiere conexión, telemetría fresca <=2 s, fase reposo para inicio/reanudar. Telemetría previa puede permanecer en memoria tras desconexión. | Probar reconexión y que no habilite práctica antes de muestra nueva; no afirmar validación. |
| P1 | mobile/lib/data/handsense_protocol.dart | Parser E/A admite campos extras, T exige cinco y porcentajes válidos. | No cambio urgente; pruebas de robustez posteriormente. |
| P1 | app/PROTOCOLO.md | Describe evento U, firmware actual emite T,U pero no evento E,U. | Documentar abstención como estado/bloqueo, no como evento recibido. |
| P1 | mobile | Comparación flex-only en UI deriva de Outcome, firmware mantiene contador independiente solo por serial. | Para evaluación experimental usar ambos contadores reales del serial, no inferir equivalencia. |
| P1 | validacion/BOM.csv, ensayos.csv | Costos y ensayos físicos vacíos, referencias a motor. | Completar con datos reales. |

## Matriz de rúbrica
25% mínimos: 2 ADC y 2 LED implementados; buzzer no habilitado, validar LEDs y confirmar interpretación docente. 20% ADC: API configura resolución/atenuación (no escrituras directas de registros PIC); explicar equivalencia ESP32 y confirmar aceptación docente. Comparación mV-DMM pendiente. 20% programación: módulos calibración/detector/sketch/Flutter, 14 grupos comprobados; integrar evidencia de código. 15% BLE: GATT HS1 bidireccional, video muestra ACK y U; faltan muestras calibradas en vivo y efecto RESET. 10% montaje/Gantt: ODS original recuperado, revisar cableado real, alimentación USB, sujeción. 10% afiche: diseño corregido, tabla pendiente, impresión a escala real.

## Fuentes técnicas
- https://docs.espressif.com/projects/arduino-esp32/en/latest/api/adc.html (C3, 11 dB)
- https://wiki.seeedstudio.com/XIAO_ESP32C3_Getting_Started/
- https://docs.espressif.com/projects/arduino-esp32/en/latest/api/preferences.html
- https://pmc.ncbi.nlm.nih.gov/articles/PMC8339513/ (antecedente cuantitativo, no rendimiento propio)

## Límites
No se verificó APK, compilación objetivo nueva ni hardware. El firmware copiado sin cambios se conserva como línea base; candidato separado requiere compilación y ensayo físico. No se ha actualizado GitHub ni el computador del equipo.
