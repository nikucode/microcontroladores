# Decisiones de UX y alcance

## Auditoría

La pantalla anterior mezclaba cinco botones de prueba, explicaciones, contador e historial. Modelos y explicaciones se conservaron. Se separaron responsabilidades sin añadir paquetes. Firmware y web no se modificaron.

## Respaldo y decisiones

- **Navegación por tarea:** cuatro destinos solicitados por Alex. Es una decisión de producto para separar preparación, ejecución, revisión y preferencias; su facilidad de uso debe probarse.
- **No evaluable separado:** sigue la evidencia y límites de [RehabBuddy](https://pubmed.ncbi.nlm.nih.gov/42964283/) sobre problemas técnicos y calibración. No convierte fallas del sensor en un juicio físico ni demuestra beneficio clínico.
- **Explicaciones persistentes por sesión:** conserva la hipótesis «Por qué se contó». [Co-diseño en terapia de mano](https://pubmed.ncbi.nlm.nih.gov/42578466/) respalda evaluar comprensión y comodidad con usuarios; no prueba que nuestras pantallas sean efectivas.
- **Origen y memoria explícitos:** todos los resultados actuales son predeterminados. El historial indica su carácter temporal y conserva la etiqueta de origen.
- **Accesibilidad:** botones con mínimo 48, texto adaptable sin recortar escala del sistema, contraste Material 3, mensajes con Semantics liveRegion, historial en listas de construcción diferida. Basado en prácticas de las skills Flutter y el principio de [mensajes de estado de W3C](https://www.w3.org/WAI/WCAG21/Understanding/status-messages). Falta comprobar TalkBack en teléfono.
- **Arquitectura:** flujo de eventos independiente de la vista y generación de ejemplos como capacidad aparte. BLE no se implementa ni se simula como conexión real.

## Avance y pendientes

La base anterior fue instalada por Alex y sus tres pruebas pasaron. Para esta revisión el análisis estático pasa, pero las pruebas nuevas y el APK están bloqueados en Codex (ver README). Próximo cierre: ejecutar pruebas, instalar y revisar el recorrido en Android. Luego definir contrato BLE con IDs y recuperación de desconexión antes de almacenar datos como mediciones reales.
