# Desafío PIC — conexiones iniciales

Esta etapa verifica alimentación y entradas analógicas. Deja desconectados los displays por ahora.

## Componentes para esta etapa

- PIC16F877A en encapsulado DIP-40.
- Fuente de +5 V y referencia GND común.
- 1 resistencia de 10 kΩ para MCLR.
- LDR y resistencia de 10 kΩ.
- Fuente ajustable de 0 a 1.5 V para emular la salida del LM35 en SimulIDE.
- Interruptor SPST y resistencia de 10 kΩ para pull-up de RB0.

## Alimentación del PIC

| Pin físico | Señal | Conectar a |
|---:|---|---|
| 1 | MCLR/VPP | +5 V mediante 10 kΩ |
| 11 | VDD | +5 V |
| 12 | VSS | GND |
| 31 | VSS | GND |
| 32 | VDD | +5 V |

En la simulación configura la frecuencia del PIC en 4 MHz. En el montaje físico se necesitará el cristal de 4 MHz y sus dos condensadores, salvo que el laboratorio indique otro circuito de reloj. Las dos tierras de VSS deben conectarse.

## Entrada LDR — AN0

Conecta el divisor así:

```text
+5 V ── resistencia 10 kΩ ──┬── RA0/AN0 (pin 2)
                             └── LDR ── GND
```

Con esta orientación, más luz reduce la resistencia de la LDR y baja la tensión en AN0. La lectura ADC disminuye con la luz. El porcentaje mostrado será una escala relativa e invertida, y dependerá de la LDR, la resistencia y la iluminación.

## Entrada LM35 — AN1

En el montaje real: `Vs` a +5 V, `GND` a GND y `Vout` a RA1/AN1 (pin 3). En SimulIDE, usa una fuente ajustable como sustituto temporal y conecta su negativo a GND común. La tensión debe estar entre 0 y 1.5 V para representar aproximadamente 0–150 °C usando la escala de 10 mV/°C.

## Selector — RB0

```text
+5 V ── resistencia 10 kΩ ──┬── RB0/INT (pin 33)
                              └── interruptor SPST ── GND
```

- Interruptor abierto: RB0 = 1, seleccionar LDR.
- Interruptor cerrado: RB0 = 0, seleccionar LM35.

## Cálculos previstos (ADC de 10 bits, Vref = 5 V)

- `temperatura_C = ADC_AN1 × 500 / 1023` para LM35 a 10 mV/°C.
- `luz_pct = 100 - (ADC_AN0 × 100 / 1023)` como porcentaje relativo e invertido de la escala ADC.

La temperatura debe limitarse o señalizarse si supera 99 °C porque solo hay dos dígitos disponibles. Al escribir el firmware se revisará el tiempo de adquisición al cambiar de canal ADC y la configuración de AN0/AN1 según el datasheet.

## Prueba antes de continuar

1. Coloca las conexiones de alimentación y confirma el +5 V/GND en SimulIDE.
2. Conecta primero solo el divisor LDR y verifica que el nodo AN0 cambia al variar la iluminación del componente.
3. Conecta la fuente emuladora a AN1 y prueba valores conocidos, por ejemplo 0.25 V para representar 25 °C.
4. Conecta el selector y confirma los niveles alto/bajo de RB0.
5. Guarda el circuito de SimulIDE y una captura antes de agregar displays.

Todavía no se puede verificar el valor ADC hasta cargar un firmware de prueba. El siguiente paso, después de armar esta etapa, será crear ese firmware y su HEX.
