# HandSense — plan de construcción

**Equipo:** Alex Díaz y María José Córdova<br>
**Estado de la propuesta:** entregada y evaluada con nota 7, según Alex.<br>
**Objetivo:** prototipo experimental que registra flexión de un dedo y fuerza relativa ejercida, cuenta repeticiones y entrega información y retroalimentación al usuario.

## Alcance acordado en el boceto

| Parte | Función | Evidencia de término |
|---|---|---|
| Sensor de flexión | Medir cambio de flexión con divisor resistivo y ADC | Valores distintos y repetibles en reposo y flexión |
| FSR | Medir fuerza relativa con divisor resistivo y ADC | Valores distintos y repetibles al presionar |
| Procesamiento | Detectar una repetición completa con estados e histéresis | Mantener el dedo flexionado cuenta una sola vez; volver a reposo habilita la siguiente |
| LED | Informar un estado definido del ejercicio | El estado del LED coincide con el valor mostrado |
| Motor vibrador | Dar retroalimentación háptica por medio de un driver | Se activa en el evento previsto sin alimentarlo desde un GPIO |
| Memoria | Recuperar parámetros de calibración tras reiniciar | Los umbrales se conservan después de apagar y encender |
| WiFi o BLE | Enviar mediciones al dashboard | Se reciben flexión, fuerza relativa, repeticiones y estado |
| Dashboard | Mostrar las cuatro variables en vivo | La vista coincide con el monitor serie y responde a cambios |

Las lecturas de flexión y FSR serán **relativas y calibradas para este montaje**. No se afirmarán grados, newtons ni utilidad clínica sin validación específica.

## Orden de trabajo

1. **Versión A: lógica observable.** Dos potenciómetros sustituyen temporalmente a los sensores. Leer dos canales ADC, mostrar valores por puerto serie, detectar estados y contar repeticiones. Un LED representa la salida visual y otro representa el motor. Cerrar esta versión antes de integrar sensores reales.
2. **Versión B: prototipo de mesa.** Sustituir cada potenciómetro por su sensor y ajustar los divisores según el componente real. Probar el motor y su etapa de control por separado. Registrar rangos de lectura y fallos observados.
3. **Versión C: integración.** Añadir calibración persistente, transmisión inalámbrica, dashboard y soporte físico. Ensayar una demostración completa y documentar resultados y límites.

## Primera prueba reproducible

Con ambos potenciómetros y el controlador conectados:

1. Registrar el valor ADC de cada entrada en reposo.
2. Girar solo el potenciómetro de flexión y verificar que cambia solo su lectura.
3. Girar solo el potenciómetro de presión y verificar que cambia solo su lectura.
4. Cruzar el umbral alto de flexión: el contador aumenta una vez.
5. Mantener la flexión por varios segundos: el contador no cambia.
6. Bajar del umbral bajo y volver a subir: el contador aumenta exactamente una vez más.
7. Superar el umbral de presión: observar la advertencia visual prevista.

Para que el resultado sea explicable, guardar por cada prueba: fecha, esquema o foto, versión de código, valores observados y conclusión.

## Datos que faltan para cerrar el circuito

- Modelo exacto de la placa ESP32.
- Modelo o especificaciones del sensor de flexión y del FSR.
- Modelo del motor vibrador y sus datos de tensión y corriente.
- Material disponible para montaje y alimentación.

Con esos datos se podrán fijar pines, resistencias, circuito del motor y lista de compras sin adivinar especificaciones.

## Fuentes del proyecto

- Propuesta HandSense entregada en la asignatura y evaluada con nota 7; el PDF original no se añade aquí porque incluye identificadores personales.
- Auditorías y revisión de antecedentes disponibles en `investigacion/`.
- Syllabus de Microcontroladores 2026-20 para evaluación y contenidos del curso.
