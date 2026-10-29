# HandSense: especificación experimental y decisiones de diseño

**Estado:** propuesta técnica para discutir y probar con el equipo; no describe un prototipo ya validado.<br>
**Fecha:** 28 de octubre de 2026.

## 1. Pregunta que acota el proyecto

¿Puede un sistema con **dos señales analógicas** distinguir una pinza pulgar–índice completa de movimientos parciales o contactos accidentales y reducir los falsos conteos frente a un detector basado solo en flexión?

Esta pregunta utiliza los componentes del boceto evaluado con nota 7. El resultado propio será una comparación experimental, no la afirmación de haber inventado el primer guante de rehabilitación. Una [revisión de 2026](https://pubmed.ncbi.nlm.nih.gov/42651219/) identifica la validación de métricas específicas de la tarea como una brecha de los sistemas de biofeedback.

## 2. Tarea única para la primera versión

Una persona inicia con índice y pulgar separados, flexiona el índice para tocar una **superficie instrumentada con FSR**, mantiene brevemente el contacto, suelta la superficie y vuelve a extender el índice. El FSR puede fijarse en un pequeño blanco plano sostenido entre los dedos o en un objeto de prueba. **Primero se probará en mesa**, sin guante final, para observar las señales y escoger la ubicación.

El blanco plano es la primera opción de montaje porque [Interlink recomienda una superficie lisa y plana y mantener constante el área y lugar donde se aplica la fuerza](https://www.interlinkelectronics.com/downloads/integration-guides/fsr-400-series-integration-guide.pdf). Colocar el FSR directamente sobre un dedo curvo sigue siendo una alternativa que se comparará si la ergonomía del blanco no funciona. Esta es una decisión mecánica provisional, no un requisito clínico.

La banda o el blanco podrían facilitar la colocación frente a un guante completo; un [estudio previo](https://pmc.ncbi.nlm.nih.gov/articles/PMC555583/) identifica dificultades al ponerse guantes ajustados en algunas personas con limitaciones de mano. Nuestro diseño tendrá que medir ese aspecto en pruebas de uso antes de presentarlo como ventaja.

**Dos variables realmente medidas:** cambio resistivo del flex sensor convertido a lectura ADC; cambio resistivo del FSR convertido a lectura ADC. No hay información suficiente para separar todas las articulaciones del índice, medir ángulos absolutos ni medir dirección o fuerza absoluta de la pinza.

## 3. Hipótesis y comparación

| ID | Hipótesis técnica | Prueba |
|---|---|---|
| H1 | El flex sensor y el FSR dan señales separables entre reposo, flexión sin contacto y contacto. | Registrar ambos ADC durante los tres estados y graficar rangos con repeticiones. |
| H2 | Exigir flexión **y** contacto seguido de liberación reduce falsos conteos frente a contar solo flexión. | Ejecutar ambos algoritmos sobre las mismas señales etiquetadas manualmente. |
| H3 | El montaje mecánico del FSR influye en la repetibilidad. | Repetir la tarea tras desmontar y montar; comparar blanco plano y ubicación sobre el dedo si ambas son viables. |

H1 puede fallar: un sensor flex sobre un dedo no necesariamente cambia lo suficiente en esta tarea. Si los rangos se superponen por ruido o colocación, se cambia la fijación o la tarea **antes** de codificar un clasificador complejo.

## 4. Regla funcional propuesta

**Estados internos:** REPOSO, FLEXIÓN DETECTADA, CONTACTO, LIBERACIÓN PENDIENTE y ERROR DE SEÑAL. Una repetición completa exige evidencia de flexión y contacto dentro de una ventana temporal, seguida de liberación de contacto y retorno del índice a reposo. No se exigirá que la flexión ocurra estrictamente antes del contacto: en una pinza real pueden comenzar casi simultáneamente. La ventana y los umbrales se ajustarán con registros del montaje, dejando una muestra independiente para evaluación.

**Eventos visibles:** repetición completa, flexión sin contacto, contacto sin flexión suficiente, contacto sin liberación y señal no confiable. El estado «presión relativa alta» puede añadirse solo cuando exista una referencia personal de comodidad para esta tarea; no se etiquetará como lesión ni riesgo médico.

**Tratamiento de señal:** lecturas periódicas de dos canales; filtro simple y visible en código; umbrales separados de entrada/salida para evitar oscilaciones; tiempos mínimos contra rebote; bloqueo del conteo cuando la calibración sea inválida o una entrada esté desconectada/saturada. El ESP32 no debe escribir muestras continuas a NVS; esta memoria se usará para parámetros de calibración. [Espressif documenta NVS para valores pequeños y relativamente estables](https://docs.espressif.com/projects/esp-idf/en/v5.5/esp32/api-reference/storage/nvs_flash.html).

## 5. Arquitectura mínima viable

```text
flex sensor ─ divisor resistivo ─ ADC 1 ─┐
                                        ├─ filtro ─ eventos ─ estados ─ LED
FSR ───────── divisor resistivo ─ ADC 1 ─┘                       ├─ driver ─ vibración
                                                                ├─ NVS: calibración
                                                                └─ WiFi → dashboard web
```

Para el **ESP32 clásico** se reservarían dos canales de ADC1, ya que [Espressif advierte que ADC2 comparte recursos con WiFi](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/peripherals/adc/adc_oneshot.html). [Espressif también advierte del ruido del ADC](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/peripherals/adc/adc_calibration.html); se medirá el ruido antes de escoger filtro o capacitor. La asignación de pines, atenuación y resistencias se hará cuando se conozca el modelo exacto de placa y sensores.

**Comunicación propuesta:** una página web servida localmente por el ESP32 en modo punto de acceso, abierta desde el navegador del teléfono. Es una aplicación web y evita depender de una cuenta o servidor externo. [Espressif documenta el modo SoftAP](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/network/esp_wifi.html?highlight=wifi_config). Si la demostración requiere conectarse a una red existente, se evaluará el modo estación. La elección final depende de la placa y de las condiciones de la sala.

**Actuadores:** LED para un estado claro de la secuencia; vibración breve en un evento elegido y visible en el dashboard. El motor requiere una etapa de control dimensionada según su tensión/corriente reales; no se fija transistor ni resistencia sin conocerlo. Durante la primera fase, un segundo LED simula la vibración.

## 6. Protocolo de prueba reproducible

1. **Registrar señales crudas:** por cada ensayo guardar fecha, versión de firmware, montaje, tiempo, ADC de flexión, ADC de FSR y anotación manual del evento. Video corto puede apoyar la anotación si el equipo consiente y evita datos personales innecesarios.
2. **Conjunto de desarrollo:** ajustar filtros, umbrales y ventanas con algunos ensayos etiquetados de cada clase.
3. **Conjunto de evaluación separado:** probar al menos 20 ensayos nuevos por clase principal: pinza completa, flexión sin contacto, contacto sin flexión y contacto mantenido. No retocar parámetros viendo esos ensayos antes de calcular métricas.
4. **Comparar detectores:** contador A = solo flexión; contador B = flexión + contacto + liberación. Mostrar matriz de confusión, falsos positivos, falsos negativos y diferencias por clase. Registrar si el detector se abstuvo por señal no confiable.
5. **Recolocación:** hacer tres ciclos de quitar y volver a montar sensores; medir cambio de línea base y repetir algunos ensayos. Si cambia demasiado, introducir recalibración explícita.
6. **Integración:** comprobar concordancia de estado entre registro serie, LED, motor y dashboard; reiniciar para verificar persistencia de calibración.

La meta de diseño es que B reduzca falsos positivos sin perder una fracción importante de pinzas completas. Se fijará una meta numérica antes de evaluar, una vez observado el ruido y la separabilidad de los sensores. En el informe se presentará el desempeño real, incluidos los fallos.

## 7. Decisiones y puertas de avance

| Puerta | Avanzar cuando… | Si falla… |
|---|---|---|
| G1: sensores | Los dos canales cambian independientemente y sus rangos útiles son mayores que el ruido. | Revisar divisor, colocación y alimentación. |
| G2: tarea | Flexión/contacto/reposo son separables en registros repetidos. | Cambiar fijación o tarea; no agregar IA para ocultar mala señal. |
| G3: algoritmo | La comparación A/B demuestra el valor o el límite de fusionar señales. | Ajustar la pregunta o el gesto; documentar resultado negativo. |
| G4: salidas | LED y motor obedecen eventos, con driver probado por separado. | Volver a prueba de mesa antes de integrar. |
| G5: sistema | Dashboard y parámetros persistentes funcionan tras reinicio y reconexión. | Mantener visualización serie como evidencia mientras se corrige comunicación. |

## 8. Alcance de la entrega

**Debe estar:** dos sensores analógicos, LED, motor vibrador, comunicación inalámbrica, dashboard con flexión/contacto relativos, estados y contador; calibración almacenada; prueba A/B documentada. **Puede esperar:** guante textil definitivo, ejercicios múltiples, batería, IA, clasificación de patologías, mediciones clínicas y una app nativa. La versión de mesa con un solo gesto permite cubrir todos los bloques evaluables con menos variables mecánicas.

## 9. Información aún necesaria

- Placa ESP32 exacta y entorno de programación disponible.
- Modelo físico de flex sensor y FSR, o acceso a ellos en laboratorio.
- Motor vibrador exacto (tensión y corriente) y fuente de alimentación.
- Posibilidad de probar el blanco FSR en mesa y registrar señales.

La lista de componentes, el esquema eléctrico final y el pinout se cerrarán con esos datos; hacerlo antes implicaría adivinar especificaciones.
