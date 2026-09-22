/*
 * descripcion: enciende un led con un pulsador
 * y lo apaga con otro pulsador
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

// pulsador de encendido conectado a ra0
#define BOTON_ON RA0

// pulsador de apagado conectado a ra1
#define BOTON_OFF RA1

void main(void)
{
    // convierte los pines analogicos del puerto a en digitales
    ADCON1 = 0x06;

    // rb0 sera salida para el led
    TRISBbits.TRISB0 = 0;

    // ra0 sera entrada para el boton de encendido
    TRISAbits.TRISA0 = 1;

    // ra1 sera entrada para el boton de apagado
    TRISAbits.TRISA1 = 1;

    // el led parte apagado
    LED = 0;

    // el programa se repite para siempre
    while(1)
    {
        // si se presiona el boton de encendido
        if(BOTON_ON == 0)
        {
            LED = 1;
        }

        // si se presiona el boton de apagado
        if(BOTON_OFF == 0)
        {
            LED = 0;
        }
    }

    return;
}