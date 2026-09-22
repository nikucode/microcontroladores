/*
 * descripcion: enciende un led cuando se presiona un pulsador
 * y lo apaga cuando se suelta
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

// led conectado a rb0
#define LED RB0

// pulsador conectado a ra0
#define PULSADOR RA0

void main(void)
{
    // convierte los pines analogicos del puerto a en digitales
    ADCON1 = 0x06;

    // rb0 sera salida para el led
    TRISBbits.TRISB0 = 0;

    // ra0 sera entrada para el pulsador
    TRISAbits.TRISA0 = 1;

    // parte con el led apagado
    PORTB = 0x00;

    // el programa se repite para siempre
    while(1)
    {
        // con pull-up, al presionar el boton ra0 pasa a 0
        if(PULSADOR == 0)
        {
            // boton presionado
            LED = 1;
        }
        else
        {
            // boton suelto
            LED = 0;
        }
    }

    return;
}