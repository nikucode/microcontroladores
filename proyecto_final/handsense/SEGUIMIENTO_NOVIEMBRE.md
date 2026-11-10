# HandSense — seguimiento, carta Gantt corta y bitácora de noviembre

**Corte:** 10 de noviembre de 2026. **Fecha interna de sistema listo:** 23 de noviembre; el día exacto de presentación debe cotejarse con el aviso vigente del curso. Esta tabla amplía, sin reemplazar, la carta Gantt de septiembre en `/home/minimodecoro/Downloads/Carta_Gantt_HandSense.ods`.

**Convención:** `Hecho` = existe evidencia enlazada; `Simulado` = probado sin sensores físicos; `Pendiente` = trabajo por realizar; `Bloqueado` = depende de un dato o pieza. No se asigna un porcentaje ficticio a tareas compuestas.

## Carta Gantt operativa

| ID | Actividad y entregable | Responsable principal propuesto | Ventana | Depende de | Estado al 10 nov. | Evidencia o criterio de cierre |
|---|---|---|---|---|---|---|
| H1 | Confirmar fecha, inventario, enlaces y plazos de piezas | Cote; fecha ambos | 10–12 nov. | Avisos del curso y cotizaciones | Pendiente | Fecha confirmada y lista con existencia, costo total y entrega |
| H2 | Cerrar placa, circuito y alimentación de un prototipo | Ambos | 12–13 nov. | H1 | Pendiente | Esquema con pines y valores justificados por modelos reales |
| H3 | Completar tabla de secuencias Wokwi | Alex | 10–13 nov. | Firmware actual | Simulado parcialmente | Registros de los seis casos, salida esperada y observada |
| H4 | Integrar firmware, memoria y dashboard con datos vivos | Alex; revisión Cote | 11–18 nov. | H2 para pinout final | Pendiente | Teléfono/computador muestra estado real; reinicio conserva calibración |
| H5 | Montar y medir ambos sensores y el driver del motor en mesa | Cote; pruebas ambos | 14–21 nov. | H1–H2, recepción de piezas | Bloqueado por piezas | ADC reposo/gesto, polaridad, ruido, corriente; LED y vibración comprobados |
| H6 | Ajustar soporte y parámetros con mediciones reales | Cote y Alex | 19–22 nov. | H5 | Pendiente | Pinza natural, colocación documentada, sin cables tirantes; umbrales registrados |
| H7 | Integración y prueba piloto comparativa | Ambos | 21–22 nov. | H4–H6 | Pendiente | Ensayos etiquetados; conteo por flexión y por fusión sobre las mismas señales; fallas descritas |
| H8 | Informe, fotos, video, BOM y presentación | Ambos | 10–22 nov., actualización por sesión | Evidencia de cada hito | Iniciado | Informe distingue simulación/mesa/uso; costos y límites incluidos |
| H9 | Sistema listo para entrega y ensayo | Ambos | 23 nov. | H7–H8 | Pendiente | Demostración reproducible y respaldo de mesa preparado |

Las ventanas H3/H4 y H1/H2/H5 se solapan para que Alex y Cote avancen en paralelo. H8 corre durante todo el trabajo: cada ensayo debe entrar al informe y a esta bitácora el mismo día.

## Plantilla de entrada de bitácora

```text
Fecha y responsables:
Objetivo de la sesión:
Trabajo realizado:
Evidencia (archivo, foto, video, log o commit):
Resultado observado y límite:
Decisión y razón:
Problema o bloqueo:
Siguiente paso, responsable y fecha:
Hitos Gantt actualizados:
```

## Entrada 03 — Auditoría de estado y calendario, 10 de noviembre de 2026

**Responsable de la revisión:** apoyo de investigación y planificación para Alex y Cote. Esta entrada documenta una auditoría de archivos, no una sesión física del equipo.

**Objetivo:** identificar brechas frente a la propuesta y preparar una ruta realizable para una sola entrega.

**Trabajo realizado:** se revisaron propuesta original, syllabus, bitácora de septiembre, carta Gantt original, firmware, app y documentos de investigación. Se hizo una revisión dirigida de literatura 2024–2026 y documentación de FSR. Se comprobó que las cinco pruebas locales de lógica y la prueba de datos de la app pasan. No se probaron sensores ni motor reales.

**Evidencia:** [revisión de evidencia](investigacion/2026-11-10_revision_para_entrega.md), [plan de hitos](PLAN_ENTREGA_25_NOV.md), [firmware y pruebas](firmware/logica_gesto/README.md), [contrato de app](app/PROTOCOLO.md).

**Resultado y límite:** la arquitectura y lógica básica están preparadas para continuar; la integración física y la comunicación en vivo siguen sin verificarse. El syllabus ubica la evaluación en la semana del 23; el 25 es una fecha estimada no confirmada.

**Decisión:** terminar internamente el 23, usar un solo prototipo, cerrar placa y compras con especificaciones reales, y actualizar bitácora/Gantt junto con cada avance técnico.

**Siguiente paso:** Alex registra `SIN_FLEXION` en Wokwi y comienza el enlace firmware–dashboard; Cote confirma inventario y enlaces/fechas de las piezas cotizadas. Es una propuesta de reparto que ambos pueden ajustar.

## Entrada 04 — Ejecución del prompt, 10 de noviembre de 2026

Se cotejó el detector con el contrato y la validación de la app. Se identificó la incompatibilidad de ESPERA_REPOSO y que el bloqueo por señal inválida sigue pendiente. Se prepararon protocolo, matriz de cierre, plantilla de ensayos, BOM sin cotizaciones inventadas e informe LaTeX/PDF. H8 avanza en documentación; H4 continúa pendiente de integración real. Las fuentes recientes se verificaron con páginas académicas y documentación oficial de Espressif.

Estimaciones iniciales de esfuerzo activo, pendientes de ajustar a la disponibilidad del equipo: H1 1–2 h; H2 2–4 h; H3 1–2 h; H4 6–10 h; H5 4–8 h; H6 2–4 h; H7 3–5 h; H8 4–6 h repartidas; H9 1–2 h. Total estimado: 24–43 horas-persona, sin contar envíos ni aprendizaje adicional. Reservar margen de corrección y revisar capacidad real antes de comprometer fechas.

El camino crítico físico pasa por recepción → circuito → calibración → integración → ensayos. El software puede avanzar en paralelo con entradas simuladas. Si no llegan sensores o motor, Wokwi queda como evidencia parcial y no satisface la demostración física. Si solo falla el soporte corporal, el montaje de mesa conserva la prueba electrónica pero no demuestra ergonomía vestible.

## Entrada 05 — Compras y guía didáctica, 10 de noviembre de 2026

Alex confirma compra de ESP32 y sensores por AliExpress y próxima visita a San Diego para complementos. H1 avanza en compra; modelos y recepción siguen pendientes. Se amplió el informe con conceptos del ramo, recorrido de la señal, reproducción de Wokwi, lectura del código y criterios de comprobación. Se tomó como referencia pedagógica el informe del Desafío PIC. La revisión no encontró licencia explícita; no se añadió ninguna sin decisión de los autores.

## Entrada 06 — Integridad de la interfaz, 10 de noviembre de 2026

Se resolvió en la app la incompatibilidad ESPERA_REPOSO. Se incorporaron presentación condicionada a conexión/calibración, mensajes accesibles y explicación desplegable. Las decisiones y fuentes están en app/DECISIONES.md. H4 avanza en contrato y presentación, pero el servidor ESP32, calibración física y persistencia continúan pendientes.
