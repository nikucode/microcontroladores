# Decisiones de interfaz — 10 de noviembre de 2026

1. **ESPERA_REPOSO:** evidencia directa en gesture_logic.h; se admite y explica en la app. La prueba de contrato verifica compatibilidad.
2. **Validez antes de porcentajes:** al fallar una respuesta o la calibración se ocultan las barras; los contadores del dispositivo no se recalculan. Inferencia de diseño apoyada por los problemas técnicos y de calibración asistida en [RehabBuddy, 2026](https://pubmed.ncbi.nlm.nih.gov/42964283/). No implica eficacia demostrada de esta interfaz.
3. **Mensaje de estado accesible:** se usa role=status con actualización moderada sin mover el foco, siguiendo [W3C SC 4.1.3](https://www.w3.org/WAI/WCAG21/Understanding/status-messages). Esto no constituye una auditoría WCAG completa.
4. **Explicación opcional:** una sección desplegable explica la regla y sus límites. La hipótesis es que mejora comprensión sin sobrecargar la vista; medir comprensión con usuarios sigue pendiente.

Verificación automatizada: contrato ESPERA_REPOSO, conexión, calibración inválida/pendiente, error de señal y recuperación. La app no implementa protección del firmware ni detección física de desconexión del sensor.
