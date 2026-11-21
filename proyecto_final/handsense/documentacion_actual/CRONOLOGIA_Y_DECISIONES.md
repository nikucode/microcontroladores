# Cronología verificable y decisiones

La cronología usa fechas Git y documentos fechados. No se atribuyen actividades a septiembre sin archivo o commit que las respalde.

| Fecha | Evidencia | Avance / decisión | Nivel |
|---|---|---|---|
| 06/09 | bitácora citada en registros de continuidad; original no recuperado | definición inicial del problema y objetivos | Referencia indirecta |
| 09/09 | Gantt original mencionada; ODS no recuperado | inicio señalado en la planificación | Referencia indirecta |
| 16/09 | segunda entrada descrita en registros; original no recuperado | revisión preliminar de arquitectura | Referencia indirecta |
| 28/10 | commits `127f564`, `0a5b177`, `4863561` | investigación, experimento acotado y ruta sin hardware | Documentado |
| 29/10 | `3f74972`–`67a0c67` | web demo, adquisición Wokwi y primera lógica de gestos | Implementado/simulado |
| 30/10 | `61118be` | salida serie legible | Implementado |
| 10/11 | `9f2e11c`–`e11d029` | cierre académico, informe, validación, estados de señal | Documentado/implementado |
| 10/11 | `917da29`, `53a0763` | app Flutter y experiencia de cuatro secciones | Implementado; APK inicial instalado |
| 20/11 | `afa241b` | inventario, montaje XIAO, Gantt y pauta 27/11 | Documentado; hardware pendiente |
| 21/11 | `b694c5e`, `f93e940` | contrato BLE, fuente Flutter, diagnóstico ESP32 y build Android | Implementado sin prueba BLE física |
| 21/11 | cambios locales de esta auditoría | detector estricto, 9 pruebas y documentación consolidada | Verificado en software; no publicado aún |

## Decisiones vigentes

- XIAO ESP32-C3 como placa objetivo, sujeto a confirmación del ejemplar físico.
- BLE directo a Flutter; Wi-Fi/HTTP queda como antecedente.
- Clasificación en ESP32 y explicación en la app.
- Secuencia estricta flexión → contacto → liberar contacto → liberar flexión.
- Un solo prototipo, alimentación USB/power bank como primera opción y motor solo con etapa validada.
- Tríptico 77 × 55 cm y feria 27/11/2026.

## Cambios de dirección

| Antes | Vigente | Motivo |
|---|---|---|
| ESP32 DevKit GPIO34/35 | XIAO ESP32-C3, ADC1 GPIO3/4 propuesto | tamaño y placa elegida; exige nueva verificación |
| Wi-Fi/HTTP y web | BLE GATT y Flutter | enlace directo sin servidor local |
| cualquier flexión cuenta | fusión y secuencia estricta | distinguir pinza de flexión aislada |
| umbrales universales | calibración individual | variación de sensor, ADC y montaje |
| póster A1 | tríptico 77×55 | pauta vigente del docente |
| fecha 23/25 | feria 27/11 | actualización oficial |

Los documentos anteriores no se borran: deben leerse como historia y remitir a `LEER_PRIMERO.md`. Su existencia no valida retroactivamente las decisiones abandonadas.
