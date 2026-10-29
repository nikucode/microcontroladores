# HandSense: antecedentes, novedad y pivotes

**Revisión exploratoria:** 28 de octubre de 2026.<br>
**Base:** propuesta de Alex Díaz y María José Córdova evaluada con nota 7.

## Veredicto

El concepto original —sensor de flexión + FSR + ESP32 + LED/vibración + dashboard + conteo— **no es novedoso por sus componentes ni por su combinación general**. Hay productos, papers y patentes que usan sensado de movimiento, fuerza, comunicación y retroalimentación para ejercicios de mano. Esto no invalida el proyecto académico. Su aporte puede ser una función más precisa, una implementación verificable y resultados experimentales propios.

Esta búsqueda **no puede demostrar que una propuesta sea inexistente en todo el mercado**. Sí permite identificar antecedentes cercanos y formular una diferencia concreta. No es una búsqueda formal de patentes ni una evaluación de libertad de operación.

## Método y límites

Se revisaron artículos originales y revisiones en PubMed/PMC, páginas oficiales de productos, fichas técnicas de sensores y ESP32, y textos de patentes en Google Patents. Términos: hand rehabilitation glove, flex sensor, FSR, force, vibrotactile feedback, repetition count, movement quality, ESP32 y finger rehabilitation patent. La búsqueda es exploratoria; las páginas comerciales describen funciones anunciadas, no prueban desempeño independiente.

## Evidencia académica

| Hallazgo | Consecuencia para HandSense |
|---|---|
| Una [revisión de 55 estudios (2026)](https://pubmed.ncbi.nlm.nih.gov/42651219/) incluye conteo, calidad de movimiento y feedback vibratorio; pide validar métricas específicas de cada tarea en condiciones reales. | El aporte interesante es definir y validar una métrica de calidad para un gesto concreto. |
| Una [revisión de wearables de extremidad superior](https://pubmed.ncbi.nlm.nih.gov/39714084/) identifica problemas de colocación y calibración. | Medir qué pasa al retirar y volver a colocar el sensor. |
| Un [estudio piloto de conteo](https://pmc.ncbi.nlm.nih.gov/articles/PMC8339513/) obtuvo 95,6 % de exactitud global con varios sensores en ejercicios de brazo; menos sensores redujeron la exactitud. | Comparar nuestro conteo con observación manual; esa cifra no es una predicción para HandSense. |
| Un [ensayo de feedback de conteos](https://pmc.ncbi.nlm.nih.gov/articles/PMC9505054/) observó mayor uso durante la intervención, sin demostrar beneficios duraderos al terminar. | No atribuir rehabilitación clínica al contador por sí solo. |
| Un [ensayo de control de fuerza digital](https://pubmed.ncbi.nlm.nih.gov/40401398/) estudia cómo se aplica la fuerza, además de la cantidad de movimientos. | Hay fundamento para estudiar fuerza y movimiento juntos. Su medición tridimensional no equivale a nuestro FSR. |
| La [ficha del FSR 400](https://www.interlinkelectronics.com/downloads/datasheets/fsr-400-series-datasheet.pdf) indica dependencia de mecánica y geometría; un [ensayo de sensores](https://pmc.ncbi.nlm.nih.gov/articles/PMC6808001/) encontró deriva y errores por curvatura y carga sostenida. | Mostrar fuerza/contacto **relativo**, sin afirmar newtons ni presión clínica. |

## Productos y patentes cercanos

| Antecedente | Funciones documentadas | Afirmación de novedad que descarta |
|---|---|---|
| [Neofect Smart Glove](https://www.neofect.com/us/smart-glove) y su [descripción oficial](https://www.neofect.com/us/blog/stroke-rehabilitation-is-now-fun-thanks-to-rapael-smart-glove) | Sensores de flexión, registro, ejercicios en app, Bluetooth y adaptación de dificultad. | Guante sensor, enlace inalámbrico, ejercicios y adaptación. |
| [Flint MusicGlove](https://www.flintrehab.com/frequently-asked-questions/) | Guante con sensores, juego de pinzas y registro de repeticiones. | Contar pinzas y mostrar progreso en una app. |
| [GripAble Home](https://gripable.co/wp-content/uploads/2021/05/GripAble-Home-User-Guide-2.4.1-16-May-2021.pdf) | Fuerza y liberación de agarre, línea base y metas. | Medir fuerza y personalizar parámetros. |
| [Tyromotion Pablo](https://www.tyromotion.com/product/pablo-functional-rehabilitation/) | Sensado inalámbrico, fuerza de agarre/liberación y accesorios modulares. | Inalámbrico, feedback o modularidad general. |
| [US20160089571A1 (2016)](https://patents.google.com/patent/US20160089571A1/en) | Describe sensores de flexión y presión y señales visuales o hápticas. | Arquitectura general de sensado más feedback. |
| [TR2024011537A2 (2024)](https://patents.google.com/patent/TR2024011537A2/en) | Describe guante con flexión, presión, enlace inalámbrico, repeticiones y control de presión excesiva. | La combinación del boceto y la alerta de fuerza alta. |
| [Estudio de Gloreha](https://pmc.ncbi.nlm.nih.gov/articles/PMC9854469/) | Describe FSR en dedos y flexión para evaluación de mano. | Combinar flexión y FSR en rehabilitación. |
| [Sistema automatizado para evaluar pinza](https://www.mdpi.com/2076-3417/10/10/3436) | Instrumenta una tarea de pinza y mide fuerza y deslizamiento con un aparato de mesa. | «Evaluar pinza» tampoco es novedoso como objetivo general. |

No conviene anunciar «primer guante con flexión y presión», «primer sistema inalámbrico» ni «primer sistema que alerta por fuerza excesiva». ESP32 es una opción de implementación, no una novedad por sí misma.

## Tres propuestas de ajuste

| Ruta | Modificación | Valor demostrable | Dificultad |
|---|---|---|---|
| **A. HandSense Calidad** | Reconocer una *pinza pulgar–índice completa*: flexión, contacto en banda relativa, liberación y extensión. Separar intentos incompletos y presión relativa alta. | Métrica explícita de calidad de una tarea, con evidencia frente a anotación manual. | Media; conserva los requisitos y componentes. |
| **B. HandSense Módulo** | Usar una banda dorsal en índice y un pequeño blanco FSR en pulgar u objeto, con electrónica separada de la mano. | Evaluar tiempo de colocación y variación tras retirar/reponer sensores. | Media-alta por mecánica; modularidad por sí sola ya existe. |
| **C. HandSense Investigación** | Comparar el contador original basado solo en flexión con un contador basado en la secuencia flexión + contacto. Publicar señales y anotaciones de pruebas técnicas. | Resultado experimental propio, reproducible y defendible aunque no sea único en el mundo. | Media; depende de un buen protocolo. |

**Recomendación:** combinar **A + C** en la entrega. Agregar **B** si el montaje y el tiempo alcanzan. Cambiar a una nueva enfermedad o prometer un tratamiento agregaría exigencias de validación fuera del alcance de esta asignatura.

**Ajuste de mayor interés técnico dentro de A:** antes de calificar la repetición, verificar si los sensores siguen entregando señales utilizables (sin saturación, desconexión aparente o cambio grande de línea base tras recolocación). Si fallan, el sistema responde «recalibrar» en lugar de emitir una evaluación engañosa. Es una función verificable que ataca un problema real de los wearables; una [revisión reciente](https://pmc.ncbi.nlm.nih.gov/articles/PMC13631400/) también recomienda considerar calidad de señal e incertidumbre. Por eso se debe presentar como **implementación propia de un principio conocido**, no como concepto nunca visto.

## Versión recomendada: HandSense Calidad

**Pregunta de ingeniería:** ¿dos sensores analógicos permiten distinguir una pinza pulgar–índice completa de flexión sin contacto, contacto sin flexión y pinza sin liberación?

**Montaje previsto:** flex sensor en índice; FSR en zona de contacto pulgar–índice o en un blanco estable; ESP32; LED; motor vibrador con driver; enlace inalámbrico; dashboard. La ubicación exacta se decidirá después de probar señal y comodidad. El FSR mide contacto/intensidad relativa y los límites se calibran para el montaje y la tarea.

**Regla inicial de estados:**

```text
REPOSO → FLEXIONADO → CONTACTO → CONTACTO LIBERADO → EXTENDIDO
                                                   ↓
                                       1 repetición completa
```

Usar histéresis y tiempo mínimo para evitar conteos múltiples por ruido. Identificar como intentos distintos: flexión sin contacto, contacto sin flexión suficiente, presión relativa sobre límite configurado y falta de liberación. No calificar una repetición si la calibración no es válida. El dashboard muestra flexión relativa, contacto relativo, etapa, repeticiones completas, intentos incompletos y motivo. Guardar umbrales solo al calibrar o cambiar la configuración.

Para un **ESP32 clásico con WiFi**, [Espressif recomienda ADC1](https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32/schematic-checklist.html?highlight=strapping+pin), ya que ADC2 comparte recursos con WiFi. Los pines se fijarán cuando se conozca la placa exacta.

## Prueba que hace defendible el aporte

1. Definir por adelantado qué se observará como repetición completa e intento incompleto.
2. Grabar o anotar 20–30 ensayos controlados de cada tipo de evento y guardar lecturas de ambos sensores.
3. Aplicar a **las mismas señales** el contador por flexión y el contador por secuencia; informar aciertos, falsos positivos, falsos negativos y matriz de confusión.
4. Repetir ensayos después de retirar y colocar de nuevo los sensores; registrar cuánto cambia la calibración.
5. Mantener contacto durante un tiempo fijo y medir deriva del FSR; comprobar que LED, vibración y dashboard coinciden con el estado interno.

Eso validaría **factibilidad técnica en el montaje ensayado**, no eficacia terapéutica, seguridad clínica ni exactitud de fuerza absoluta.

## Título y aporte para la presentación

**Título sugerido:** *HandSense Calidad: prototipo de evaluación de pinza pulgar–índice mediante flexión y contacto relativos*.

**Aporte defendible:** «Diseñamos y evaluamos una regla interpretable que clasifica repeticiones completas e incompletas de una tarea de pinza con dos sensores analógicos, calibración individual y retroalimentación local e inalámbrica. Comparamos su conteo con uno basado solo en flexión y reportamos sus errores».

**Decisión inmediata:** elegir la tarea exacta y probar si la colocación del flex sensor y del FSR produce señales separables y repetibles. Si no, ajustar la mecánica antes de complejizar el software.
