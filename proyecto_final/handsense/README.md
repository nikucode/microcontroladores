# Proyecto final: HandSense

Proyecto de Alex Díaz y María José Córdova para la asignatura de Microcontroladores. La propuesta inicial fue evaluada con nota 7.

HandSense es un prototipo experimental para observar ejercicios simples de mano mediante dos sensores analógicos, retroalimentación visual y háptica, y una interfaz inalámbrica. El equipo construirá un solo prototipo físico para la entrega de noviembre de 2026. El syllabus sitúa la evaluación en la semana del 23; el día 25 es una fecha estimada por confirmar.

## Documentos

- [Informe de avances PDF](informe/avance.pdf) y [fuente LaTeX](informe/avance.tex).
- [Protocolo y matriz de cierre](validacion/PROTOCOLO_Y_CIERRE.md), [BOM pendiente](validacion/BOM.csv) y [plantilla de ensayos](validacion/ensayos.csv).

- [Revisión de evidencia para la entrega](investigacion/2026-11-10_revision_para_entrega.md): qué está demostrado, antecedentes recientes, hipótesis de aporte y riesgos.
- [Prompt maestro de planificación](PROMPT_MAESTRO_PLANIFICACION.md): instrucciones reutilizables para actualizar plan, informe, carta Gantt y visión futura con evidencia.
- [Seguimiento de noviembre](SEGUIMIENTO_NOVIEMBRE.md): carta Gantt operativa y bitácora que se actualizan con cada sesión.
- [Ruta a la entrega de noviembre](PLAN_ENTREGA_25_NOV.md): estado actual, decisiones pendientes, tareas de Alex y Cote, fechas y pruebas para una demostración completa.
- [Plan de trabajo](PLAN_DE_TRABAJO.md): requisitos y pruebas previstos para el prototipo.
- [Investigación de antecedentes, novedad y pivotes](investigacion/2026-10-28_antecedentes_novedad_y_pivotes.md): comparación con publicaciones, patentes y productos; propuesta de ajuste.
- [Especificación experimental](investigacion/2026-10-28_especificacion_experimental.md): tarea elegida para investigar, hipótesis, arquitectura provisional y pruebas de decisión.
- [Ruta sin hardware](RUTA_SIN_HARDWARE.md): herramientas, pasos de simulación y evidencia que se puede producir antes del montaje físico.
- [App web de demostración](app/README.md): panel accesible con datos simulados y contrato HTTP previsto para conectar el ESP32.
- [Investigación previa](investigacion/README.md): auditorías técnicas y materiales del curso.

## Estado

La [primera adquisición en Wokwi](firmware/adquisicion/README.md) incluye circuito con dos potenciómetros y firmware con salida CSV. Tres grabaciones documentan la puesta en marcha, la corrección de terminales y la respuesta independiente de ambos canales.

La [segunda simulación](firmware/logica_gesto/README.md) agrega filtro, histéresis, estados, conteo y LED para intentos completos e incompletos.

La arquitectura propuesta usa ESP32. Los documentos iniciales mencionan una duda sobre su aceptación en la asignatura; se conservaron como registro histórico. La propuesta que incluía ESP32 fue entregada y evaluada con nota 7, según el equipo. Aún no hay evidencia de sensores, motor ni dashboard validados físicamente.

El proyecto se describe como un **prototipo experimental**, sin afirmar eficacia terapéutica ni mediciones clínicas de fuerza o ángulo.
