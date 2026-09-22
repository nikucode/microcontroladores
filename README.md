# microcontroladores

Repositorio de trabajos, ejercicios y prácticas desarrolladas para la asignatura de **Microcontroladores** de Ingeniería en Automatización y Robótica.

Este espacio reúne actividades realizadas en lenguaje C, desde ejercicios básicos de programación hasta simulaciones con el microcontrolador **PIC16F877A**, trabajando progresivamente con entradas y salidas digitales, pulsadores, LED y secuencias de control.

El repositorio forma parte del trabajo colaborativo desarrollado por **nikucode** durante la asignatura.

---

## Integrantes

- **María José Córdova**
- **Alex Díaz**

---

## Contenido del repositorio

### Trabajo Colaborativo N°1

Primer conjunto de ejercicios enfocados principalmente en programación en lenguaje C y resolución de problemas.

#### `parte-1-post-clase/`

Contiene los ejercicios recomendados para realizar fuera de clase, desde el Ejercicio 3 al 40.

#### `parte-2-portafolio/`

Contiene los problemas tipo Portafolio, desde el Problema 1 al 22.

#### `capturas/`

Incluye capturas de los códigos y sus respectivas ejecuciones utilizadas como evidencia durante el desarrollo del trabajo.

---

### Trabajo Colaborativo N°2

Conjunto de actividades enfocadas en el uso de **entradas y salidas digitales del PIC16F877A** mediante MPLAB X, XC8 y SimulIDE.

El trabajo comienza con el control básico de un LED y avanza progresivamente hacia circuitos con pulsadores y un sistema de dos semáforos.

#### Actividad 1: LED parpadeante

Primer ejercicio orientado al control de una salida digital.

- LED conectado a RB0.
- Configuración del puerto B como salida.
- Encendido y apagado periódico del LED.
- Uso de retardos con `__delay_ms()`.

#### Actividad 2: LED controlado mediante pulsador

Se incorpora una entrada digital para controlar el estado de un LED.

- Pulsador conectado a RA0.
- LED conectado a RB0.
- Uso de resistencia pull-up.
- Configuración de RA0 como entrada digital.
- Lógica activa en bajo:
  - pulsador suelto → estado lógico `1`
  - pulsador presionado → estado lógico `0`

#### Actividad 3: Control alternado de dos LED

Se utilizan dos salidas digitales controladas mediante un pulsador.

- LED 1 conectado a RB0.
- LED 2 conectado a RB1.
- Pulsador conectado a RA0.
- Los LED cambian de estado de forma alternada dependiendo del estado del pulsador.

#### Actividad 4: Control de un LED mediante dos pulsadores

Se incorporan dos entradas digitales independientes.

- RA0 utilizado para encender el LED.
- RA1 utilizado para apagar el LED.
- LED conectado a RB0.
- El LED mantiene su estado después de liberar el pulsador.

#### Actividad 5: Semáforo doble

Actividad final que integra los conceptos trabajados anteriormente.

Se utilizan seis LED para representar dos semáforos:

**Semáforo 1**

- RB0 → verde
- RB1 → amarillo
- RB2 → rojo

**Semáforo 2**

- RB3 → verde
- RB4 → amarillo
- RB5 → rojo

Además:

- RA0 se utiliza como entrada para activar la secuencia.
- La secuencia está dividida en cuatro fases.
- Cada fase tiene una duración de 1 segundo.
- El ciclo se repite mientras el interruptor permanece activado.

Las fases implementadas son:

1. Semáforo 1 en verde y Semáforo 2 en rojo.
2. Semáforo 1 en amarillo y Semáforo 2 en rojo.
3. Semáforo 1 en rojo y Semáforo 2 en verde.
4. Semáforo 1 en rojo y Semáforo 2 en amarillo.

---

## Estructura general

La organización actual del repositorio es:

```text
microcontroladores/
├── parte-1-post-clase/
├── parte-2-portafolio/
├── capturas/
└── trabajo_colaborativo_2/
    ├── README.md
    ├── main.tex
    ├── informe_trabajo_colaborativo_2.pdf
    ├── actividad_1_led_parpadeante/
    │   └── led_parpadeante.c
    ├── actividad_2_led_pulsador/
    │   └── led_pulsador.c
    ├── actividad_3_leds_alternados/
    │   └── leds_alternados.c
    ├── actividad_4_dos_pulsadores/
    │   └── led_dos_pulsadores.c
    ├── actividad_5_semaforo_doble/
    │   └── semaforo_doble.c
    └── imagenes/
        ├── actividad1_simulide.png
        ├── actividad2_apagado.png
        ├── actividad2_encendido.png
        ├── actividad3_led1.png
        ├── actividad3_led2.png
        ├── actividad4_apagado.png
        ├── actividad4_encendido.png
        ├── actividad5_fase1.png
        ├── actividad5_fase2.png
        ├── actividad5_fase3.png
        └── actividad5_fase4.png
```

---

## Tecnologías utilizadas

### Programación

- C
- GCC

### Microcontroladores

- PIC16F877A
- MPLAB X IDE
- MPLAB XC8

### Simulación

- SimulIDE

### Documentación

- Markdown
- LaTeX

### Herramientas

- Visual Studio Code
- Git
- GitHub

---

## Conceptos trabajados

A medida que fuimos avanzando en los trabajos también fuimos pasando desde ejercicios de programación general en C hacia la relación entre código, microcontrolador y circuito.

Entre los conceptos trabajados se encuentran:

- estructuras de control en C;
- compilación y ejecución de programas;
- configuración de entradas y salidas digitales;
- registros `TRIS` y `PORT`;
- configuración de pines digitales mediante `ADCON1`;
- resistencias pull-up;
- lógica activa en bajo;
- uso de pulsadores como entradas digitales;
- control de LED como salidas digitales;
- temporización con `__delay_ms()`;
- generación y carga de archivos `.hex`;
- configuración del PIC16F877A;
- uso del pin MCLR;
- configuración de frecuencia del microcontrolador;
- simulación de circuitos en SimulIDE;
- secuencias de control;
- organización y documentación de proyectos con Git y GitHub;
- documentación técnica mediante LaTeX.

---

## Aprendizajes durante el desarrollo

Durante estos ejercicios fuimos entendiendo de una forma más práctica cómo se relaciona el código con el comportamiento del microcontrolador.

Al comienzo algunas cosas resultaban confusas, especialmente la diferencia entre entradas y salidas, el funcionamiento de los registros `TRIS`, la lógica de los pulsadores con resistencias pull-up y la relación entre los pines definidos en el programa y las conexiones realizadas en SimulIDE.

También aprendimos que cuando una simulación no funciona, el problema no necesariamente se encuentra solamente en el código.

Durante las actividades fue necesario revisar distintos elementos, por ejemplo:

- que los pines utilizados en el circuito coincidieran con los definidos en el programa;
- que los pines del puerto A estuvieran configurados como digitales mediante `ADCON1`;
- que la frecuencia configurada en SimulIDE coincidiera con los 4 MHz definidos mediante `_XTAL_FREQ`;
- que el pin MCLR se mantuviera en un nivel lógico alto;
- que el archivo `.hex` utilizado correspondiera a la compilación correcta del proyecto.

A medida que avanzamos desde el control de un solo LED hasta la secuencia de dos semáforos, estos conceptos se fueron haciendo más claros porque era posible observar directamente cómo cada cambio en el programa o en el circuito modificaba el comportamiento de la simulación.

---

## Informe en LaTeX

Además de los ejercicios, se realizó una documentación complementaria en LaTeX para organizar los códigos, capturas de simulación y los principales aprendizajes obtenidos durante las actividades.

El archivo fuente se encuentra en:

```text
trabajo_colaborativo_2/main.tex
```

y el PDF compilado en:

```text
trabajo_colaborativo_2/informe_trabajo_colaborativo_2.pdf
```

Este documento funciona como documentación complementaria del trabajo y no reemplaza necesariamente el formato oficial solicitado para la entrega de la asignatura.

---

## Sobre nikucode

**nikucode** es un espacio colaborativo donde documentamos proyectos, ejercicios y experimentos relacionados con programación, electrónica, automatización, ciencia y tecnología.

Este repositorio corresponde específicamente al trabajo realizado durante la asignatura de Microcontroladores.