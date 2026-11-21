# Inventario, compras y repuestos — especificación de referencia

**Corte: 20-11-2026.** No afirmar «ya comprado» sin boleta/foto/inventario. El hecho de que Alex y Cote hayan salido a comprar NO demuestra cuáles piezas específicas adquirieron.

## A. Núcleo del prototipo (verificar existencia física)
| Componente | Cantidad para prototipo | Estado verificable | Función / notas |
|---|---:|---|---|
| **Seeed Studio XIAO ESP32-C3 con antena** | 1 | **Modelo elegido; posesión física por reconfirmar** | MCU, ADC 3,3 V, lógica, BLE. Comprobar U.FL/antena y pines soldados |
| **Sensor flexivo resistivo de 2,2 pulgadas** | 1 | Cotizado/encargado históricamente; **recepción no verificada** | Medir flexión relativa del índice, no grados sin calibración |
| **FSR402** | 1 | Cotizado/encargado históricamente; **recepción no verificada** | Detectar contacto/presión relativa, no newtons sin calibración |
| **Motor vibrador pequeño** | 1 instalado + 1 opcional repuesto | Modelo y tensión **sin confirmar** | Realimentación háptica, alimentación independiente dimensionada |
| **LED verde y LED ámbar** | 1 de cada uno + 1 de repuesto cada uno | Inventario por confirmar | Resultado completo / aviso o incompleto |

**Precios cotizados en capturas anteriores (NO precios vigentes ni confirmación de pago):** XIAO $5.400 CLP, flexivo $5.600, FSR402 $1.865. No usar estas cifras como costo real facturado.

## B. Electrónica: valores y cantidades de compra sugeridos
| Elemento | Valor / característica | Cantidad compra | Cantidad mínima instalada | Propósito / condición |
|---|---|---:|---:|---|
| Resistencia R1 | **47 kΩ**, ¼ W, 1 % preferible | 5–6 | 1 | Parte superior divisor flexivo, valor **inicial** |
| Resistencia R2 | **10 kΩ**, ¼ W | 5–6 | 1 | Parte inferior divisor FSR, valor **inicial** |
| Resistencia R3 y R4 | **330 Ω**, ¼ W | 5–6 | 2 | Limitación corriente LED |
| Resistencias alternativas | **22 kΩ** | 5 | 0 | Ajustar divisor tras medir sensores |
| Resistencias alternativas | **220 Ω** | 4 | 0 | LED alternativo tras cálculo |
| Resistencia puerta MOSFET | **100–330 Ω**, ¼ W | 4–5 total | 1 si MOSFET discreto | Entre GPIO y gate; depende de driver |
| Resistencia pull-down gate | **100 kΩ**, ¼ W | 3–5 | 1 si MOSFET discreto | Gate a GND: motor apagado al arranque |
| MOSFET N lógico | RDS(on) especificada con VGS ≤3,3 V; corriente suficiente | 2 | 1 si motor suelto | Driver de motor. **No asumir IRF520**; verificar pines reales |
| Diodo protección | **1N5819** o **1N4007**, según motor | 2–3 | 1 si corresponde | Protección transitorios; orientación a revisar |
| Condensador cerámico | **100 nF**, ≥10 V | 5 | según circuito | Desacoplamiento y pruebas |
| Electrolíticos | **10 µF y 100 µF**, ≥10 V | 2 de cada | según circuito | Reserva alimentación; verificar polaridad |
| Protoboard de ensayo | aprox. 400 puntos | 1 | 1 de laboratorio | Primera prueba, no soporte wearable |
| Placa perforada | pequeña | 1–2 | 1 | Cableado robusto final |
| Tiras de pines | 2,54 mm, compatibles | 1–2 | si XIAO sin headers | Conexión de placa |
| Cables Dupont | M-M y M-H | 1 juego cada uno | según circuito | Prototipado |
| Cable flexible aislado | 26–28 AWG aproximado | 2 m | según recorrido | Montaje vestible con alivio de tensión |
| Conectores sensores | modelo que **no dañe lámina flexible** | 2–4 | 2 | Desmontaje, sujeción mecánica y contacto confiable |
| Termorretráctil | surtido | 1 | según unión | Aislamiento |
| Cable USB-C de **datos** | 1 | 1 si falta | 1 | Programación/alimentación |

**Alternativa:** si se adquiere un módulo vibrador con transistor/driver incorporado compatible con 3,3 V, **no duplicar** MOSFET/diodo sin revisar sus especificaciones.

## C. Montaje textil y herramientas
| Material | Cantidad sugerida | Para qué |
|---|---|---|
| Velcro suave | 30–50 cm | Cierre ajustable |
| Elástico textil | 0,5–1 m | Sostén sensor sin restringir articulación |
| Tela acolchada/neopreno | 1 retazo | Muñequera y protección |
| Multímetro | 1 disponible o prestado | Continuidad, V, R, verificación antes de encender |
| Power bank 5 V USB | 1 existente o prestado | Alimentación portátil por USB; motor requiere análisis aparte |
| Transportador | 1 disponible | Referencias angulares para calibración |

## D. Lista de comprobación del inventario REAL (rellenar al comprar)
| Ítem | Comprado (sí/no/?) | Cantidad disponible | Modelo exacto y enlace/foto/boleta | Fecha |
|---|---|---|---|---|
| XIAO ESP32-C3 | ? | ? | | |
| Sensor flexivo 2,2" | ? | ? | | |
| FSR402 | ? | ? | | |
| Motor | ? | ? | **tensión y corriente obligatorias** | |
| MOSFET/módulo driver | ? | ? | **modelo y encapsulado** | |
| LED / R / C / protoboard | ? | ? | | |
| Cables / conectores / soporte | ? | ? | | |

## E. Pendientes bloqueantes
1. Motor real (3 V/5 V, corriente de arranque) y driver real: **NO energizar antes de comprobar**.
2. Direcciones de curvatura/terminales del sensor flexivo y FSR reales.
3. Presencia de antena externa XIAO; tipo de headers; tamaño/cortes de rieles protoboard.
4. Registrar qué se compró efectivamente en la salida del 20-11 y precios finales. **No reemplazar datos faltantes por la lista sugerida.**
