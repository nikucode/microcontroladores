# Evolución documentada de HandSense (septiembre–noviembre de 2026)

**Precisión:** una fecha de archivo prueba la existencia del documento ese día; no certifica que todo el trabajo haya comenzado exactamente entonces. Las ventanas entre hitos son reconstrucciones. La carta Gantt original `Carta_Gantt_HandSense.ods` (septiembre) fue mencionada en una sesión Codex, pero no está disponible en `main`.

| Fecha o período | Avance/decisión | Respaldo y alcance |
|---|---|---|
| 06 sep. | Definición inicial de problema y objetivos | Bitácora de septiembre citada en registro Codex; documento original no publicado aquí |
| 09 sep. | Inicio señalado en Gantt original | Registro Codex que menciona ODS, no el archivo recuperado |
| 16 sep. | Revisión preliminar de arquitectura | Segunda entrada de bitácora descrita en registro Codex |
| Sept.–oct. | Investigación de productos, métodos y componentes | Investigación fechada y auditorías; rango reconstruido |
| 28 oct. | Antecedentes, hipótesis y especificación de pinza | [Antecedentes](../investigacion/2026-10-28_antecedentes_novedad_y_pivotes.md), [Especificación](../investigacion/2026-10-28_especificacion_experimental.md) |
| Octubre–nov. | Adquisición Wokwi + lógica, filtro/histéresis y conteos | [Adquisición](../firmware/adquisicion/), [Gestos](../firmware/logica_gesto/); intervalos no exhaustivos |
| 04–10 nov. | Versión web de demostración, investigación y documentación de cierre | [App web](../app/), [SEGUIMIENTO](../SEGUIMIENTO_NOVIEMBRE.md) |
| 10 nov. | Auditoría de fin de curso, BOM, validación y README anteriores | [Seguimiento](../SEGUIMIENTO_NOVIEMBRE.md) |
| 18–19 nov. | Flutter Android, integración BLE en código, pruebas y APK | Registros Codex/terminal compartidos, **código móvil local todavía ausente en main** |
| 20 nov. | XIAO elegido; pinout/diagramas, inventario, tríptico correcto y Gantt de cierre | [Documentación actual](../LEER_PRIMERO.md) |
| 27 nov. | Feria 9:00–13:00 | Fecha indicada en rúbrica oficial; hito futuro al corte |

## Decisiones que cambiaron y por qué
| Antes | Ahora | Razón |
|---|---|---|
| ESP32 DevKit con GPIO34/35 | XIAO ESP32-C3 con ADC1 GPIO3/4 propuesto | Tamaño vestible y disponibilidad; requiere pruebas de placa real |
| Wi-Fi/HTTP con app web | BLE GATT con Flutter Android | App nativa instalada y comunicación directa con teléfono |
| Conteo simple flexión | Fusionar flexión + contacto y explicar intento | Reducir conteos por flexión sin pinza en la hipótesis |
| Umbral ADC fijo de simulación | Calibración individual y referencia de voltaje | Resistencia y montaje físico variables |
| Posibilidad de A1 | Tríptico 77×55 | Formato obligatorio de docente |
| Entrega estimada 23/25 nov. | Feria confirmada 27 nov. | Rúbrica de fecha reciente |
| Tareas repartidas por secciones de póster | Cote integra tríptico; Alex aporta capturas/resultados | Evita fragmentación y mantiene identidad visual |

## Qué significan los documentos históricos
No borrar las propuestas de Wi-Fi, PIC, dashboard web y fechas anteriores: revelan decisiones y aprendizaje. Añadir una etiqueta **HISTÓRICO** y remitir al README actual para que nadie las interprete como instrucciones vigentes. Las propuestas anteriores **no se validan retroactivamente** por el hecho de existir código nuevo.
