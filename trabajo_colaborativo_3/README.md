# Trabajo Colaborativo 3

Trabajo desarrollado para la asignatura de Microcontroladores, enfocado en el manejo de entradas y salidas con el PIC16F877A utilizando MPLAB X, XC8 y SimulIDE.

## Actividades realizadas

### Actividad 1 - Control de display por segmentos

Se realizó un programa de diagnóstico para un display de 7 segmentos de cátodo común.

El programa recorre los pines RB0 a RB7 y enciende un segmento a la vez durante un segundo, permitiendo identificar visualmente qué segmento corresponde a cada salida del microcontrolador.

Archivos:

- `actividad_1_display_segmentos/display_segmentos.c`

### Actividad 2 - Contador de 0 a 9

Se implementó un contador de 0 a 9 utilizando un display de 7 segmentos de cátodo común y un pulsador conectado a RA0.

El mapeo utilizado fue:

- RB0 → a
- RB1 → b
- RB2 → c
- RB3 → d
- RB4 → e
- RB5 → f
- RB6 → g
- RB7 → dp

Se utilizó una resistencia pull-up de 10 kΩ en RA0. Cada vez que se presiona y suelta el pulsador, el contador avanza al siguiente número y vuelve a 0 después del 9.

Archivos:

- `actividad_2_display_contador/display_contador.c`

### Actividad 3 - Manejo de LCD 16x2

Se utilizó un LCD HD44780 en modo de 4 bits conectado al PORTD del PIC16F877A.

Conexiones principales:

- RS → RD2
- E → RD3
- R/W → GND
- D4 → RD4
- D5 → RD5
- D6 → RD6
- D7 → RD7

El programa inicializa el LCD y muestra un mensaje en pantalla.

Archivos:

- `actividad_3_lcd/lcd_mensaje.c`
- `actividad_3_lcd/lcd_mensaje.sim1`

## Evidencias

Las capturas de las simulaciones se encuentran en la carpeta `imagenes/`.

## Informe

El documento final del trabajo se encuentra en:

`informe/Trabajo Colaborativo 3 alex diaz maria jose cordova.pdf`