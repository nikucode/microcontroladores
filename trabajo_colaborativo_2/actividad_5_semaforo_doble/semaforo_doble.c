/*
 * descripcion: controla dos semaforos con seis leds
 * la secuencia funciona mientras el interruptor esta activado
 */

// configuracion del pic
#pragma config FOSC = XT
#pragma config WDTE = OFF
#pragma config PWRTE = ON
#pragma config BOREN = ON
#pragma config LVP = OFF
#pragma config CPD = OFF
#pragma config WRT = OFF
#pragma config CP = OFF

// libreria principal para usar el pic con xc8
#include <xc.h>

// frecuencia del cristal
#define _XTAL_FREQ 4000000

// semaforo 1
#define VERDE1 RB0
#define AMARILLO1 RB1
#define ROJO1 RB2

// semaforo 2
#define VERDE2 RB3
#define AMARILLO2 RB4
#define ROJO2 RB5

// interruptor conectado a ra0
#define INTERRUPTOR RA0

void main(void)
{
    // convierte los pines analogicos del puerto a en digitales
    ADCON1 = 0x06;

    // rb0 a rb5 seran salidas
    TRISBbits.TRISB0 = 0;
    TRISBbits.TRISB1 = 0;
    TRISBbits.TRISB2 = 0;
    TRISBbits.TRISB3 = 0;
    TRISBbits.TRISB4 = 0;
    TRISBbits.TRISB5 = 0;

    // ra0 sera entrada para el interruptor
    TRISAbits.TRISA0 = 1;

    // parte con todos los leds apagados
    PORTB = 0x00;

    while(1)
    {
        // con pull-up, el interruptor activado entrega 0
        if(INTERRUPTOR == 0)
        {
            // fase 1
            // semaforo 1 verde
            // semaforo 2 rojo

            VERDE1 = 1;
            AMARILLO1 = 0;
            ROJO1 = 0;

            VERDE2 = 0;
            AMARILLO2 = 0;
            ROJO2 = 1;

            __delay_ms(1000);


            // fase 2
            // semaforo 1 amarillo
            // semaforo 2 rojo

            VERDE1 = 0;
            AMARILLO1 = 1;
            ROJO1 = 0;

            VERDE2 = 0;
            AMARILLO2 = 0;
            ROJO2 = 1;

            __delay_ms(1000);


            // fase 3
            // semaforo 1 rojo
            // semaforo 2 verde

            VERDE1 = 0;
            AMARILLO1 = 0;
            ROJO1 = 1;

            VERDE2 = 1;
            AMARILLO2 = 0;
            ROJO2 = 0;

            __delay_ms(1000);


            // fase 4
            // semaforo 1 rojo
            // semaforo 2 amarillo

            VERDE1 = 0;
            AMARILLO1 = 0;
            ROJO1 = 1;

            VERDE2 = 0;
            AMARILLO2 = 1;
            ROJO2 = 0;

            __delay_ms(1000);
        }
        else
        {
            // si el interruptor esta apagado, todos los leds quedan apagados
            PORTB = 0x00;
        }
    }

    return;
}