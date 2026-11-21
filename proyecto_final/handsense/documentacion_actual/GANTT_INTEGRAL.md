# HandSense — carta Gantt integral (septiembre–noviembre de 2026)

**Integrantes:** Alex Díaz y María José Córdoba. **Entrega oficial:** viernes 27 de noviembre de 2026, 09:00–13:00.

> Esta tabla reconstruye el recorrido completo desde antecedentes y bitácora de septiembre, documentos fechados 28 de octubre y 10 de noviembre y sesiones Codex del 18–20 de noviembre. **Las ventanas históricas aproximadas no deben confundirse con fechas de actividad comprobadas.** No representa trabajo diario. La carta original `~/Downloads/Carta_Gantt_HandSense.ods` fue citada, pero no está disponible en GitHub; comparar cuando se recupere.

| ID | Actividad | Responsable | Período documentado o previsto | Evidencia / estado |
|---|---|---|---|---|
| 01 | Formulación de problema y alcance | Ambos | 06–09 sep | Antecedente fechado 06/09; inicio ODS 09/09 |
| 02 | Propuesta académica y objetivos | Ambos | 09–16 sep | Ventana reconstruida |
| 03 | Revisión de arquitectura y requisitos | Ambos | 09–16 sep | Revisión fechada 16/09 |
| 04 | Carta Gantt inicial | Ambos | 09–16 sep | ODS histórico citado, no localizado |
| 05 | Investigación de antecedentes y novedad | Alex Díaz | sep–28 oct | Documento de investigación 28/10 |
| 06 | Diseño experimental de pinza | Alex Díaz | sep–28 oct | Especificación 28/10 |
| 07 | Selección de sensores/MCU/actuadores | María José Córdoba | sep–10 nov | Cotizaciones y BOM |
| 08 | Adquisición simulada Wokwi ADC | Alex Díaz | oct–04 nov | Firmware y trazas de simulación |
| 09 | Filtro, histéresis y detector | Alex Díaz | 28 oct–10 nov | Código y cinco pruebas C++ |
| 10 | Primera aplicación demostrativa y Android | Alex Díaz | 04–10 nov | Registros Codex; fechas aproximadas |
| 11 | Interfaz Android cuatro pantallas | Alex Díaz | 04–18 nov | Registros Codex |
| 12 | Validación de gestos y escenarios | Alex Díaz | 04–19 nov | Wokwi/5 tests C++ |
| 13 | Informe y protocolo de cierre | Ambos | 28 oct–20 nov | Informe/seguimiento publicado |
| 14 | Confirmación XIAO y BLE | Ambos | 10–20 nov | Decisiones confirmadas en conversación |
| 15 | Código diagnóstico BLE Flutter/ESP32 | Alex Díaz | 18–20 nov | Preparado en entorno Codex local |
| 16 | Pruebas Flutter y APK | Alex Díaz | 18–20 nov | 7 tests y build documentados |
| 17 | Netlist, pinout y diseños físicos | María José Córdoba | 19–23 nov | Esquema preparado, .fzz no validado |
| 18 | Inventario y compras definitivas | María José Córdoba | 20–22 nov | Pendiente inventario real |
| 19 | Consolidación documental GitHub | Alex Díaz | 20–24 nov | PR #1 incorporado, PR #2 borrador |
| 20 | Sensores y conversión ADC física | María José Córdoba | 21–25 nov | Pendiente |
| 21 | Etapa de potencia y actuadores | María José Córdoba | 21–25 nov | Pendiente |
| 22 | BLE real y respuesta a comandos | Alex Díaz | 21–25 nov | Pendiente |
| 23 | Calibración con referencias | María José Córdoba | 22–25 nov | Pendiente |
| 24 | Integración del prototipo | Ambos | 23–26 nov | Pendiente |
| 25 | Soporte vestible y ergonomía | María José Córdoba | 23–26 nov | Pendiente |
| 26 | Pruebas integradas y reconexión | Ambos | 24–26 nov | Pendiente |
| 27 | Diseño del tríptico 77×55 | María José Córdoba | 20–26 nov | Pendiente versión final |
| 28 | Cierre técnico, evidencias y Gantt | Alex Díaz | 24–26 nov | Pendiente |
| 29 | Ensayo general | Ambos | 26 nov | Pendiente |
| 30 | Feria de proyectos | Ambos | 27 nov · 09:00–13:00 | Fecha confirmada en rúbrica |

## Interpretación
- **Historia:** el hecho de que un documento tenga fecha no prueba actividad continua durante toda la ventana.
- **Software:** pruebas C++ y Flutter no acreditan automáticamente prueba electrónica real.
- **Pendiente:** reemplazar fechas y estados por evidencia registrada después de cada sesión; no inventar avance porcentual.
- **Camino crítico:** inventario/modelos → protoboard y ADC → driver motor → comunicación BLE real → integración → ensayos → feria.
- **Coordinación:** Cote integra el tríptico completo y el montaje; Alex integra firmware, Flutter y código. Ensayo conjunto obligatorio; no repartir pedazos de un mismo panel.

## Fuentes internas
- [Cronología y decisiones](CRONOLOGIA_Y_DECISIONES.md)
- [Seguimiento histórico de noviembre](../SEGUIMIENTO_NOVIEMBRE.md)
- [Gantt de cierre](GANTT_VIGENTE.md)
- [Rúbrica](RUBRICA_Y_AFICHE.md)

**Para entregar:** anexar también la versión PDF/XLSX integral generada y revisar la eventual carta ODS original antes de asegurar fechas de inicio/fin exactas.
