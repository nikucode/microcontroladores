# Evidencias, procedencia y pendientes

## Qué existe o se observó
| Área | Evidencia reportada | Qué NO demuestra |
|---|---|---|
| Firmware lógica Wokwi | Pinza completa y flexión sin contacto observadas; cinco pruebas C++ superadas | Respuesta de sensores físicos |
| App Flutter local | 7 tests pasan, análisis limpio, APK debug compilado | Que BLE físico funcione ni que APK actualizado esté instalado |
| BLE diagnóstico local Codex | Firmware y parser preparados; comando `HS1,C,PING` → `HS1,A,PING,OK` | Que la placa respondió realmente |
| Netlist XIAO | Divisores, LED y pinout propuestos | Que existe un .fzz válido o montaje medido |
| Documentación afiche | Diseño A1 y planificación previa | Que cumple tríptico obligatorio 77×55 |
| Compras | Cotizaciones AliExpress y visita a componentes mencionadas | Cantidades o modelos efectivamente comprados |

## Documentos/archivos pendientes de subir desde computador local
- `proyecto_final/handsense/mobile/` completo de **código fuente útil** (excluir build, .dart_tool, secretos, SDK).
- `proyecto_final/handsense/firmware/ble_diagnostico/sketch.ino` local y `app/PROTOCOLO.md` BLE actualizado, revisados en conjunto.
- Pruebas Flutter y firmware, cambios de Gradle/paquetes, README del móvil.
- `Carta_Gantt_HandSense.ods` original si se encuentra en Downloads: **archivar como histórico**, no reemplazar sin comparación.
- Fritzing `.fzz` real **cuando exista**; no confundir SVG/CSV con montaje verificado.
- Fotografías reales, tabla de voltajes y errores, video y capturas reales del móvil, cuando existan.
- Tríptico 77×55 terminado y material de la pauta como referencia (no reutilizar póster A1 en lugar de tríptico).

## Evidencia mínima para la feria
1. Foto inventario y conexión clara; multímetro y valores ADC.
2. Video de LED + motor con circuito validado.
3. nRF Connect y app Flutter con notificación real + comando confirmado.
4. Pruebas de pinza completa, incompleta, repetición, error y recuperación.
5. Captura del tríptico con resultados auténticos.

## Disciplina documental
Cada medición adjunta debe tener fecha, autor, modelo, configuración, valor esperado, observado, método y conclusión. Marcar **simulación / cálculo / banco / wearable**. Los archivos históricos no se sobrescriben sin conservar trazabilidad.
