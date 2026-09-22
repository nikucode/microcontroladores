/*
 * descripcion: controla dos leds de forma alternada
 * mediante un pulsador
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

// leds conectados al puerto b
#define LED1 RB0
#define LED2 RB1

// pulsador conectado a ra0
#define PULSADOR RA0

void main(void)
{
    // convierte los pines analogicos del puerto a en digitales
    ADCON1 = 0x06;

    // rb0 sera salida para el led 1
    TRISBbits.TRISB0 = 0;

    // rb1 sera salida para el led 2
    TRISBbits.TRISB1 = 0;

    // ra0 sera entrada para el pulsador
    TRISAbits.TRISA0 = 1;

    // deja el puerto b apagado al iniciar
    PORTB = 0x00;

    // el programa se repite para siempre
    while(1)
    {
        // si el boton esta presionado
        if(PULSADOR == 0)
        {
            // apaga el led 1
            LED1 = 0;

            // enciende el led 2
            LED2 = 1;
        }
        else
        {
            // enciende el led 1
            LED1 = 1;

            // apaga el led 2
            LED2 = 0;
        }
    }

    return;
}