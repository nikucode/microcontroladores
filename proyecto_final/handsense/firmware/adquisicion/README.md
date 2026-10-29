# Primera adquisición de HandSense

Estado: archivos preparados para Wokwi; todavía no ejecutados en el simulador ni en una placa física.

## Ejecutar

1. Crear un proyecto [ESP32 en Wokwi](https://wokwi.com/projects/new/esp32).
2. Reemplazar `sketch.ino` y `diagram.json` por los archivos de esta carpeta.
3. Iniciar la simulación y abrir el monitor serie (115200 baudios).
4. Mover el potenciómetro «Flexión» manteniendo «Contacto» quieto. Debe cambiar `flex_adc` y permanecer estable `contacto_adc`.
5. Repetir con «Contacto». Luego mover ambos y registrar mínimos, valores intermedios y máximos.

La salida es CSV: tiempo desde el arranque, dos lecturas ADC y dos porcentajes del rango ADC de 12 bits. Estos porcentajes **no son la calibración del montaje** exigida por la app; no deben enviarse como si ya fueran flexión/contacto calibrados.

## Conexiones de simulación

| Entrada | Señal | Alimentación |
|---|---|---|
| Potenciómetro de flexión | SIG → GPIO34 | VCC → 3V3; GND → GND |
| Potenciómetro de contacto | SIG → GPIO35 | VCC → 3V3; GND → GND |

GPIO34 y GPIO35 son entradas ADC1 del ESP32 clásico elegido para esta simulación. La placa física y sus conexiones se confirmarán cuando el equipo tenga hardware.

## Evidencia que falta obtener

| Ensayo | Flex ADC | Contacto ADC | Resultado |
|---|---|---|---|
| Ambos al mínimo | pendiente | pendiente | pendiente |
| Flexión al medio, contacto mínimo | pendiente | pendiente | pendiente |
| Flexión al máximo, contacto mínimo | pendiente | pendiente | pendiente |
| Flexión mínimo, contacto al medio | pendiente | pendiente | pendiente |
| Flexión mínimo, contacto al máximo | pendiente | pendiente | pendiente |

Guardar el CSV del monitor serie y anotar la configuración de cada ensayo. Esta prueba comprueba adquisición independiente. Después se implementarán calibración, filtro, histéresis y estados con pruebas reproducibles, antes de publicar los datos en la API.

Referencias: [simulación ESP32](https://docs.wokwi.com/guides/esp32), [potenciómetro y límites de la simulación analógica](https://docs.wokwi.com/parts/wokwi-potentiometer), [formato del circuito](https://docs.wokwi.com/diagram-format).
