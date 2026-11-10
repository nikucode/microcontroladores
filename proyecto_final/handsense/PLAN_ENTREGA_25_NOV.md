# HandSense — ruta a la entrega del 25 de noviembre de 2026

**Equipo:** Alex Díaz y María José Córdova (Cote).

**Meta:** un solo prototipo físico demostrable. Las simulaciones y pruebas de mesa son etapas de ese prototipo, no versiones adicionales para comprar o fabricar.

**Fecha:** 10 de noviembre de 2026. Este calendario es una propuesta de trabajo; la disponibilidad de piezas aún debe confirmarse.

## Qué debe mostrar la demostración

Una pinza pulgar–índice cambia dos señales analógicas (flexión y FSR). El ESP32 reconoce una secuencia completa, aumenta el contador una sola vez y muestra las lecturas, el estado y las repeticiones en un teléfono o computador mediante una conexión inalámbrica. El LED y el motor vibrador responden al evento definido. Tras reiniciar el equipo, recupera los parámetros de calibración guardados en memoria no volátil.

Estos son los elementos comprometidos en la propuesta entregada al curso. Las magnitudes serán **relativas al montaje**: no presentaremos la señal del FSR como fuerza en newtons ni la del sensor flexivo como ángulo en grados. Una prueba con pocas repeticiones será una verificación funcional, no evidencia clínica ni estadística de eficacia.

## Estado comprobado al 10 de noviembre

| Parte | Estado | Prueba que falta |
|---|---|---|
| Dos entradas ADC con potenciómetros | Simuladas en Wokwi con ESP32 DevKit | Reemplazarlas por los sensores elegidos y medir sus rangos reales |
| Máquina de estados y conteo | Código separado; cinco pruebas locales pasan. El equipo reportó en Wokwi una pinza completa y una flexión sin contacto | Registrar las demás secuencias en Wokwi y repetirlas con sensores físicos |
| LED | Representado en Wokwi | Verificar el LED físico |
| Motor vibrador | Pendiente | Elegir motor, etapa de control y alimentación; probarlos en mesa |
| Dashboard | Existe una app con datos simulados y un contrato HTTP propuesto | Conectar firmware y app por Wi-Fi; verificar datos en vivo |
| Calibración persistente | Pendiente | Medir señales, guardar parámetros y comprobar su recuperación tras reinicio |
| Soporte para la mano | Pendiente | Ajustar sensores y cables sin impedir una pinza natural |

## Decisiones que cierran el diseño

1. **Placa:** usar el ESP32 que se pueda conseguir a tiempo y probar de inmediato. El XIAO ESP32-C3 cotizado es candidato, pero el código de Wokwi usa GPIO34/35 de un ESP32 DevKit; si se compra el XIAO habrá que reasignar pines y volver a verificar el ADC. No fijar la placa por su tamaño antes de confirmar entrega y disponibilidad.
2. **Sensores:** conservar el FSR402 y el flexivo de 2,2 pulgadas como candidatos. Los anuncios y precios compartidos anteriormente no bastan para fijar resistencias ni asegurar autenticidad. Medir la resistencia de cada sensor real en reposo y durante el gesto antes de elegir divisor, polaridad y umbrales.
3. **Motor y energía:** escoger **un** motor compatible con la alimentación disponible, con tensión y corriente documentadas. Controlarlo con una etapa de potencia; no conectarlo a un GPIO. Para esta entrega, USB desde un power bank es una opción portátil que evita añadir una batería LiPo y un cargador al camino crítico.
4. **Comunicación:** usar una sola ruta de integración: Wi-Fi con el contrato `app/PROTOCOLO.md`. El teléfono o computador debe recibir el estado real del ESP32; la vista de datos simulados no cumple la demostración final.

## Trabajo en paralelo

| Responsable | Hasta el 13 de noviembre | Entregable |
|---|---|---|
| **Cote** | Confirmar inventario propio o prestado; enviar enlaces exactos, precio total y fecha estimada de llegada de placa, FSR, flexivo y **un** motor. Bosquejar soporte ajustable y ubicación de sensor, cables y electrónica. | Lista de compra de una página + dibujo/foto del soporte |
| **Alex** | Registrar en Wokwi contacto sin flexión, falta de liberación y dos pinzas seguidas. Implementar el primer enlace real entre firmware y `GET /api/estado`, usando entradas simuladas. | Registro de pruebas + dashboard que muestre datos enviados por el ESP32 |
| **Ambos** | Elegir una placa y cerrar la compra o préstamo según disponibilidad real. | Decisión de placa, pines y fecha de recepción |

La división permite avanzar en simultáneo. Ambos deben conocer el circuito y la lógica para explicar la demostración. Cote puede concentrarse en materiales y soporte mientras Alex cierra firmware y comunicación; las mediciones y la integración física se hacen juntos.

## Hitos con fecha

| Fecha límite | Resultado visible | Si algo se retrasa |
|---|---|---|
| **12 nov.** | Inventario y enlaces exactos con entrega estimada; registrar las tres pruebas Wokwi pendientes | Buscar préstamo o proveedor local antes de depender de AliExpress |
| **13 nov.** | Placa, motor, alimentación y forma de comunicación definidos; compra/préstamo resuelto | Mantener ESP32 DevKit como opción de montaje si el XIAO no llega |
| **18 nov.** | Dashboard recibe lecturas y eventos del ESP32; acciones y almacenamiento probados primero con entradas simuladas | Priorizar estado en vivo y recuperación de calibración; documentar cualquier acción de la app que falte |
| **21 nov.** | Ambos sensores y motor probados por separado en mesa; rangos ADC, polaridad y consumo registrados | Corregir circuito y umbrales con medidas, sin copiar los límites de Wokwi |
| **23 nov.** | Sistema integrado en soporte; prueba completa y prueba incompleta; reinicio y reconexión verificados | Usar montaje de mesa ordenado como respaldo de demostración y explicar la limitación del soporte |
| **24 nov.** | Video corto de demostración, fotos del circuito, resultados, código y presentación cerrados | Reservar el día para corregir fallas y ensayar, no para añadir funciones |
| **25 nov.** | Entrega y demostración | Llevar respaldo de firmware, documentación y evidencia de pruebas |

## Registro mínimo para defender el prototipo

Guardar por cada prueba: fecha, placa y versión del código, conexiones o foto, valores ADC en reposo y durante el gesto, salida esperada, salida observada y conclusión. Demostrar al menos una pinza completa, una flexión sin contacto, dos pinzas consecutivas, reinicio con calibración recuperada y datos concordantes entre monitor serie y dashboard. Registrar aparte si LED y vibración se activan en el evento previsto.

## Primer paso al retomar HandSense

Alex: en la simulación actual, probar **contacto sin flexión** con ambos potenciómetros inicialmente en cero; subir y bajar solo el de contacto (D35) y anotar `fusion`, `flex_solo`, `inc` y `evento`. Se espera `fusion=0`, `flex_solo=0`, `inc=1`, `SIN_FLEXION`.

Cote: compartir los **enlaces exactos** de los cuatro productos ya vistos y su fecha estimada de entrega, más un inventario de lo que pueden conseguir sin compra. La información anterior contiene precios vistos en capturas, no precios o plazos confirmados hoy.

## Referencias internas

- Propuesta original del curso: `proyecto_alexdiaz_mariajosecordova.pdf` (no se copia al repositorio porque contiene identificadores personales).
- [Requisitos y alcance](PLAN_DE_TRABAJO.md).
- [Contrato firmware–app](app/PROTOCOLO.md).
- [Pruebas de la lógica](firmware/logica_gesto/README.md).
