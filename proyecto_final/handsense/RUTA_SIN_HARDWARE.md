# HandSense: ruta de trabajo antes de tener hardware

**Estado:** plan de trabajo, no resultados experimentales. **Fecha:** 28 de octubre de 2026.

## Herramienta para cada objetivo

| Objetivo | Herramienta recomendada | Límite |
|---|---|---|
| Simular el firmware ESP32 y las entradas/salidas | [Wokwi](https://docs.wokwi.com/guides/esp32) con ESP32, dos potenciómetros y dos LED | [La simulación analógica es básica](https://docs.wokwi.com/parts/wokwi-potentiometer); no reproduce la respuesta real del flex sensor ni del FSR. |
| Reforzar ADC, interrupciones o EEPROM del curso con PIC16F877A | MPLAB X + XC8 + [SimulIDE](https://simulide.com/p/mcus/) | SimulIDE lista PIC/AVR/I51/Arduino; no simula el ESP32 del proyecto. |
| Dibujar el montaje y entregar esquemas | Fritzing y esquema eléctrico legible | [Fritzing documenta prototipos](https://fritzing.org/); su simulación es limitada y no sustituye la prueba física. |
| Escribir y ordenar firmware/documentación | VS Code + Git; LaTeX para el informe | El código debe quedar versionado y cada resultado debe indicar si es simulado o físico. |
| Explorar divisores y circuitos básicos | Tinkercad Circuits | [Autodesk destaca Arduino y micro:bit](https://www.tinkercad.com/circuits); no será la referencia para el firmware ESP32. |

## Orden de construcción

### Paso 1 — especificar un solo gesto

Partir con la pinza pulgar–índice descrita en [la especificación experimental](investigacion/2026-10-28_especificacion_experimental.md). Definir por escrito qué es una repetición completa y qué intentos no deben contarse. La tarea y la lógica pueden cambiar si los sensores reales no separan bien los estados.

**Entregable:** tabla de casos: reposo, flexión sin contacto, contacto sin flexión, pinza completa, contacto sostenido y retorno a reposo.

### Paso 2 — dos entradas en Wokwi

Crear un proyecto ESP32 con POT1 = flexión simulada y POT2 = contacto simulado, conectados a **dos entradas ADC1** si la placa simulada es un ESP32 clásico. Mostrar ambas lecturas por monitor serie. Girar cada potenciómetro por separado y comprobar que solo cambia su variable.

**Cierre:** captura del circuito, código y registro de al menos cinco pares de lecturas representativos. No convertir aún esos números a grados o newtons.

### Paso 3 — lógica sin interfaz

Implementar primero un contador de referencia que usa solo flexión. Luego implementar estados que exigen flexión, contacto y liberación. Probar secuencias manuales con los potenciómetros y registrar cuándo incrementa cada contador. Añadir histéresis para evitar múltiples conteos mientras se mantiene una posición.

**Cierre:** ambos algoritmos reaccionan de forma predecible a la misma tabla de casos; los errores quedan anotados.

### Paso 4 — salidas simuladas

LED1 indica el estado definido para la demostración. LED2 representa provisionalmente al motor vibrador. Un pulsador puede activar calibración si se incluye en la versión final. Mantener los eventos de salida breves y comprobables desde el monitor serie.

**Cierre:** entrada, decisión y salida coinciden en cada caso de la tabla.

### Paso 5 — dashboard y memoria

Diseñar primero una página web sencilla que muestre los datos de prueba: flexión relativa, contacto relativo, estado, repeticiones completas e intentos incompletos. Después conectar el firmware a la página. En Wokwi la simulación WiFi existe, pero [abrir desde un navegador un servidor HTTP dentro del ESP32 simulado requiere el IoT Gateway](https://docs.wokwi.com/guides/esp32-wifi); no hacer depender la validación inicial de ese acceso. La extensión [Wokwi para VS Code incluye una pasarela local](https://docs.wokwi.com/vscode/project-config) si el equipo decide usarla.

Probar almacenamiento de parámetros de calibración y reinicio en un módulo separado. Guardar solo al cambiar parámetros, no cada muestra.

**Cierre:** dashboard con datos de prueba y prueba de persistencia documentada. El enlace inalámbrico completo se marca «simulado» hasta verificarlo en el dispositivo real.

### Paso 6 — preparar montaje físico sin inventar valores

Conseguir o identificar modelo de placa, flex sensor, FSR y motor. Consultar sus fichas y medir resistencias/rangos de trabajo cuando lleguen. Entonces elegir resistencias de divisores, pines, fuente y driver del motor. Dibujar el esquema eléctrico y su vista de montaje. El FSR se probará primero sobre una superficie plana para reducir variación mecánica.

**Cierre:** lista de materiales exacta y esquema revisado, con valores justificados.

### Paso 7 — validar con sensores reales

Probar cada sensor por separado, después ambos juntos, luego LED y motor con driver, y finalmente comunicación y dashboard. Comparar conteo por flexión con conteo combinado frente a ensayos observados manualmente. Registrar fallos, recolocación y deriva del FSR.

**Cierre:** tablas y gráficos con resultados reales; cada afirmación del informe debe distinguir simulación, medición física e inferencia.

## Informe en LaTeX

Estructura sugerida: problema y objetivo → antecedentes y competidores → alcance del prototipo → arquitectura y componentes → algoritmo → protocolo de pruebas → resultados simulados → resultados físicos → discusión de errores y límites → conclusiones y trabajo futuro. Añadir referencias con DOI/URL, fecha de consulta para productos y figuras propias del circuito.

## Próxima acción única

Construir **Paso 2**: ESP32 + dos potenciómetros + monitor serie en Wokwi. Antes de hablar de umbrales, obtener una tabla corta de lecturas de ambas entradas. Esto prueba la adquisición de dos canales sin esperar la compra de sensores.
