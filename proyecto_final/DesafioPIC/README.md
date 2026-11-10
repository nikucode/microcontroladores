# Desafío PIC

Proyecto final para desarrollar una aplicación con el PIC16F877A que lea un LM35 y una LDR, permita seleccionar el sensor mediante un interruptor y muestre la temperatura o el porcentaje relativo de iluminación en dos displays de 7 segmentos.

## Requisitos de la pauta

- PIC16F877A.
- Dos entradas analógicas: LM35 y LDR.
- Interruptor para seleccionar cuál lectura se presenta.
- Mostrar temperatura del LM35 o intensidad luminosa en porcentaje.
- Entregar simulación en SimulIDE o Proteus, código C y archivo HEX.
- Implementar físicamente el circuito con el PIC en protoboard.

## Decisiones iniciales

- Frecuencia de trabajo: 4 MHz.
- AN0 (RA0, pin 2): divisor resistivo de la LDR.
- AN1 (RA1, pin 3): salida del LM35; en SimulIDE se emula inicialmente con una fuente ajustable.
- RB0 (pin 33): selector con resistencia pull-up; abierto selecciona LDR y cerrado selecciona LM35.
- Dos displays multiplexados de cátodo común.
- Los displays muestran un valor entero de 00 a 99. La posición del selector identifica qué magnitud se está mostrando; se documentará esta limitación y se buscará una forma clara de indicar la unidad durante la implementación.
- El porcentaje de LDR será relativo a la escala ADC, no una medición calibrada en lux.

## Simulación funcional

- Circuito para entregar: [DesafioPIC.sim1](DesafioPIC.sim1). Guarda la ruta relativa `firmware/sensores.hex` y recarga ese archivo al iniciar la simulación.
- Firmware: [sensores.c](firmware/sensores.c) y [sensores.hex](firmware/sensores.hex), compilados para PIC16F877A a 4 MHz.
- Informe con capturas y procedimiento: [PDF](informe/informe_desafiopic.pdf) y [fuente LaTeX](informe/informe_desafiopic.tex).
- En esta versión de SimulIDE el componente disponible figura como `p16F877`. El firmware se compila para el PIC16F877A solicitado.
- El LM35 se representa mediante una fuente ajustable: 0,250 V equivale a 25 °C. En el montaje físico se usará el sensor LM35.
- Interruptor abierto: porcentaje relativo de luz según la LDR. Interruptor cerrado: temperatura en °C.
- Se comprobó en SimulIDE la lectura de 25 °C con 0,250 V y que el valor de luz cambia al variar la LDR.

## Comprobación antes de entregar

1. Abrir `DesafioPIC.sim1` desde esta carpeta y arrancar la simulación. Si no aparece ninguna lectura, cargar manualmente `firmware/sensores.hex` desde el menú contextual del PIC.
2. Con el interruptor cerrado y la fuente ajustada a 0,250 V, comprobar que los displays muestran aproximadamente 25 °C. La resolución del ADC puede desplazar la lectura un grado si la fuente se ajusta con la perilla y solo muestra dos decimales.
3. Abrir el interruptor y mover la perilla de la LDR; comprobar que cambia el valor mostrado.
4. Volver a cerrar el interruptor y comprobar que se muestra de nuevo la temperatura.

## Pendiente para la implementación física

- Montar el PIC16F877A con alimentación, reloj de 4 MHz, LM35, LDR, selector y dos displays en protoboard.
- Confirmar el orden de patas del LM35, de los transistores y de los displays contra las fichas técnicas de los componentes adquiridos.
- Los dos displays solo muestran `00` a `99`; el firmware limita a `99` cualquier lectura calculada superior, incluido el extremo de 100 % de luz. Esta limitación debe explicarse durante la demostración.

[Conexiones iniciales y criterios de entrada](documentacion/CONEXIONES_INICIALES.md).
