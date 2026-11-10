# HandSense — revisión de evidencia y decisiones para la entrega

**Corte de búsqueda:** 10 de noviembre de 2026. Revisión dirigida de fuentes primarias, revisiones recientes, documentación del fabricante y documentos del curso. No es una revisión sistemática exhaustiva ni una búsqueda formal de patentes.

## 1. Hechos del proyecto

- La propuesta entregada exige **dos sensores analógicos, dos actuadores (LED y motor), comunicación inalámbrica y visualización en una app**. La planificación inicial también contempla parámetros en memoria no volátil. Fuente local: `/home/minimodecoro/Downloads/proyecto_alexdiaz_mariajosecordova.pdf`.
- La bitácora anterior ya existe en `/home/minimodecoro/Downloads/Planeación_de_Proyectos_Tercera_Evaluación.pdf`; tiene entradas del 6 y 16 de septiembre. La carta Gantt original está en `/home/minimodecoro/Downloads/Carta_Gantt_HandSense.ods`. Esos archivos son antecedentes: las fechas, responsables y porcentajes reales deben actualizarse, conservando historia y marcando cambios.
- El syllabus local `/home/minimodecoro/Downloads/Syllabus Microcontroladores Semestre 2026-20.pdf` sitúa **entrega y presentación de proyectos finales, 30 %, en la semana del 23 de noviembre**. El 25 mencionado por Alex debe confirmarse con una comunicación vigente del curso. Planificar como si fuera el 23.
- El firmware de Wokwi usa un ESP32 DevKit, dos potenciómetros en GPIO34/35, LED y una lógica de estados. Hay cinco pruebas locales del algoritmo; el equipo reportó dos secuencias vistas en Wokwi. La app muestra datos simulados y tiene un contrato HTTP, pero **no recibe aún mediciones físicas del ESP32**. Tampoco están validados sensores reales, motor, persistencia ni soporte corporal.
- La selección de XIAO ESP32-C3, FSR402, flex sensor de 2,2 pulgadas y motor corresponde a cotizaciones antiguas compartidas en la conversación. Faltan enlaces exactos, existencia, corriente/tensión del motor, disponibilidad local y fecha de entrega. El subtotal citado anteriormente **no es un presupuesto final verificado**.

## 2. Evidencia externa que cambia el diseño

| Fuente | Hallazgo verificable | Decisión para HandSense | Límite |
|---|---|---|---|
| [Mei et al., revisión de 55 estudios, 2026](https://pubmed.ncbi.nlm.nih.gov/42651219/) | La medición de calidad de movimiento y el biofeedback tienen promesa, pero falta validar métricas específicas de la tarea en contextos reales. | Definir una sola pinza y una regla visible: flexión, contacto, liberación y regreso a reposo. | Una revisión de otros sistemas no valida HandSense. |
| [SensorE Exoskeleton, estudio con 30 adultos sanos, 2026](https://pubmed.ncbi.nlm.nih.gov/41604714/) | Ya existe un wearable que mide flexión de dedos y fuerza de la yema; comparó señales con referencias externas. | No atribuir novedad a la pareja de sensores. Diferenciar por tarea, simplicidad, costo total, calibración y experiencia de uso medidos. | Sus cifras no se transfieren a nuestro FSR ni a nuestro prototipo. |
| [RehabBuddy, estudio de factibilidad, 2026](https://pubmed.ncbi.nlm.nih.gov/42964283/) | Problemas técnicos y calibración asistida impidieron concluir factibilidad de uso doméstico independiente. | Evaluar si una persona puede colocarlo, calibrarlo y entender el resultado con instrucciones breves. | Su dispositivo y población difieren de HandSense. |
| [Co-diseño en terapia de mano, 2026](https://pubmed.ncbi.nlm.nih.gov/42578466/) | Consumidores y clínicos destacaron comodidad, capacidad, calma y factores del contexto; la evaluación cambió al escuchar usuarios. | Formular preguntas cortas de comodidad, comprensión y obstáculos; no limitarse a exactitud del algoritmo. | Estudia realidad virtual en terapia de mano, no este hardware. |
| [Entrenador háptico de mano, estudio de usabilidad, 2024](https://pubmed.ncbi.nlm.nih.gov/38638360/) | Una prueba con usuarios novatos encontró valor en medir preparación, fijación e instrucciones, además de función. | Cronometrar colocación y registrar si cables o soporte impiden el gesto. | Su dispositivo es un entrenador mecánico, no un contador de pinza. |
| [Sensibilidad vibrotáctil de mano y muñeca, 2025](https://pubmed.ncbi.nlm.nih.gov/39178351/) | El movimiento reduce la detección de vibraciones; la ubicación afecta la percepción. | Verificar con usuarios si el pulso se percibe durante la pinza. No asumir que una vibración eléctrica implica feedback útil. | No define el motor, intensidad ni ubicación óptima para HandSense. |
| [Guía de integración FSR 400, Interlink](https://www.interlinkelectronics.com/downloads/integration-guides/fsr-400-series-integration-guide.pdf) | La respuesta depende del área, lugar y modo de aplicación de la fuerza; el FSR da resultados cualitativos si la mecánica varía. | Usarlo inicialmente para contacto/intensidad relativa, con soporte de presión repetible y recalibración tras recolocar. | Los valores de la ficha solo corresponden a sensores auténticos y a sus condiciones de ensayo. |
| [Informe mundial OMS/UNICEF sobre tecnología de apoyo, 2022](https://www.who.int/publications-detail-redirect/9789240049451) | La asequibilidad y la participación de usuarios son problemas centrales de acceso. | Medir costo completo y esfuerzo de colocación; entrevistar usuarios potenciales antes de afirmar accesibilidad. | La necesidad mundial de tecnología de apoyo no equivale al mercado de HandSense. |

La revisión anterior del repositorio también identifica competidores, patentes y otras soluciones. Este corte añade evidencia reciente y un foco de diseño; no borra esa investigación.

## 3. Hipótesis de diferenciación, todavía sin validar

**Propuesta concreta:** un instrumento experimental de pinza pulgar–índice, de bajo costo y montaje ajustable, que informa **por qué** contó o no contó una repetición y avisa cuando la señal o la calibración no permiten interpretarla. El dashboard funciona localmente, sin cuenta ni servidor externo. La retroalimentación se prueba durante el gesto y el equipo publica límites y errores observados.

La combinación de flexión, contacto, vibración y dashboard no es única. La hipótesis de valor es que **explicabilidad + colocación sencilla + costo total bajo + medición honesta de calidad de señal** pueden hacer más útil esta tarea concreta. Para defenderla hay que medir, al menos, aciertos/errores de conteo, tiempo de colocación, cambio de señal al recolocar, comprensión de mensajes y costo de componentes, ensamblaje y reposición. La satisfacción o intención de uso requiere conversar con personas potencialmente usuarias y profesionales; no puede inferirse de una maqueta ni de literatura ajena.

El usuario final, comprador y pagador **no están definidos**. Podrían ser personas que practican ejercicios de mano, terapeutas, centros, universidades o programas comunitarios, pero son segmentos hipotéticos. La revisión de mercado debe preguntar quién experimenta el problema, quién decide la compra, qué alternativas usa y qué valor pagaría. No extrapolar cifras de prevalencia a ingresos ni prometer interés inversor.

## 4. Lo posible para la evaluación y lo posterior

**Hasta el 23 de noviembre:** un prototipo físico, una pinza definida, dos señales analógicas, LED y vibración con driver, calibración persistente, dashboard inalámbrico, prueba de conteo frente a observación manual, registro de fallas y costo real. Un pequeño piloto de comodidad con adultos voluntarios puede informar el diseño, pero no valida utilidad clínica. Cada resultado debe indicar si es simulado, probado en mesa o probado sobre la mano.

**Después de la evaluación:** entrevistas y co-diseño con personas de distintas capacidades de mano y terapeutas; prueba de colocación independiente y confort; comparación de soporte de dedo y blanco de mesa; mejora de mantenimiento y documentación abierta; estudio con muestras mayores y protocolo definido antes de recolectar datos; análisis de costo de producción y reparación. Cualquier afirmación de rehabilitación, seguridad clínica o producto médico requerirá validación y revisión regulatoria aplicable antes de comercializarse como tal.

## 5. Riesgos que deben aparecer en el informe y en la Gantt

1. **Fecha incierta:** 23 en syllabus, 25 según aviso recordado. Decisión práctica: terminar el 23 hasta confirmar por escrito.
2. **Piezas inciertas:** cotizaciones sin enlaces ni plazo confirmado. Cote verifica inventario/préstamo/proveedor local antes de depender de AliExpress.
3. **Integración incompleta:** el dashboard aún usa datos simulados; Wi-Fi, API, memoria y motor están en el camino crítico.
4. **Señal física desconocida:** los umbrales de potenciómetros de Wokwi no se trasladan directamente al sensor real. Medir ruido, polaridad y rango antes de calibrar.
5. **Novedad y valor aún hipotéticos:** reportar antecedentes cercanos y criterios de comparación. No presentar el prototipo como tratamiento ni como producto listo para vender.

## 6. Método de actualización de la evidencia

Para ampliar la investigación, buscar estudios originales y revisiones 2024–2026 en PubMed, IEEE Xplore y Google Scholar con términos `pinch rehabilitation wearable`, `finger flexion pressure sensor validation`, `hand therapy usability co-design`, `wearable biofeedback calibration` y equivalentes en español. Registrar fecha de búsqueda, consulta, DOI, diseño, muestra, tarea, medida de resultado, limitaciones y aplicación concreta a HandSense. Priorizar estudios originales para afirmaciones de desempeño y fabricantes para límites eléctricos. Separar hechos publicados, inferencias de diseño y resultados propios. Actualizar el análisis si aparecen trabajos nuevos o si cambian las piezas reales.
