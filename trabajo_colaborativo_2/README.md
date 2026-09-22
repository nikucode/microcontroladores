# Trabajo Colaborativo 2 - Entradas y salidas digitales

Ejercicios realizados para la asignatura de Microcontroladores de Ingeniería en Automatización y Robótica.

En este trabajo usamos el PIC16F877A para practicar el manejo de entradas y salidas digitales, comenzando con el control de un LED y avanzando hasta una secuencia de dos semáforos.

## Herramientas utilizadas

- PIC16F877A
- MPLAB X IDE
- XC8
- SimulIDE
- lenguaje C

## Actividades

### 1. LED parpadeante

Primer ejercicio para trabajar con una salida digital.

El LED conectado a RB0 se enciende durante 500 ms y luego se apaga durante otros 500 ms.

### 2. LED controlado mediante pulsador

Se agregó un pulsador conectado a RA0 como entrada digital.

Trabajamos con una resistencia pull-up, por lo que:

- pulsador suelto -> RA0 = 1
- pulsador presionado -> RA0 = 0

El LED conectado a RB0 se enciende mientras el pulsador está presionado.

### 3. Dos LED alternados

Se controlan dos LED mediante un pulsador.

Dependiendo del estado de RA0:

- LED 1 encendido / LED 2 apagado
- LED 1 apagado / LED 2 encendido

### 4. Encendido y apagado mediante dos pulsadores

Se utilizan dos entradas:

- RA0 para encender el LED
- RA1 para apagar el LED

En este ejercicio aprendimos que el estado del LED se puede mantener aunque el pulsador ya haya sido liberado.

### 5. Semáforo doble

Este ejercicio integra seis salidas digitales y una entrada.

Semáforo 1:

- RB0 -> verde
- RB1 -> amarillo
- RB2 -> rojo

Semáforo 2:

- RB3 -> verde
- RB4 -> amarillo
- RB5 -> rojo

La secuencia se divide en cuatro fases de un segundo.

## Algunas cosas que aprendimos

Durante estos ejercicios tuvimos que entender mejor la diferencia entre entradas y salidas, el funcionamiento de TRIS y PORT, el uso de ADCON1 para utilizar el puerto A como digital y la lógica de los pulsadores con resistencias pull-up.

También aprendimos que cuando una simulación no funciona el problema no necesariamente está en el código. Tuvimos que revisar cosas como los pines utilizados, la frecuencia del PIC, MCLR y las conexiones realizadas en SimulIDE.

## Estructura

Cada carpeta contiene el código C utilizado para una actividad.

Las capturas de las simulaciones se encuentran en la carpeta `imagenes/`.