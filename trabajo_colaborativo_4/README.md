# Trabajo Colaborativo 4

Trabajo desarrollado para la asignatura de Microcontroladores, enfocado en el manejo de entradas analógicas utilizando el ADC del PIC16F877A.

## LCD + ADC con potenciómetro

Para la simulación se utilizó un potenciómetro de 10 kΩ como entrada analógica en RA0/AN0, representando temporalmente la señal que podría entregar un sensor LM35.

El PIC16F877A utiliza su conversor ADC de 10 bits para transformar el voltaje de entrada en un valor entre 0 y 1023.

Luego se calcula el voltaje equivalente en milivoltios mediante:

`mV = (valorADC * 5000) / 1023`

Los resultados se muestran en un LCD 16x2 HD44780.

### Conexiones del potenciómetro

- Terminal 1 → +5 V
- Cursor → RA0 / AN0
- Terminal 3 → GND

### Conexiones del LCD

- RS → RD2
- E → RD3
- R/W → GND
- D4 → RD4
- D5 → RD5
- D6 → RD6
- D7 → RD7

## Archivos

- `lcd_adc_potenciometro/lcd_adc_potenciometro.c`
- `lcd_adc_potenciometro/lcd_adc_potenciometro.sim1`

## Evidencias

Las capturas de la simulación se encuentran en la carpeta `imagenes/`.

- `adc_valor_inicial.png`
- `adc_valor_modificado.png`

## Informe

El informe final será agregado a la carpeta `informe/`.