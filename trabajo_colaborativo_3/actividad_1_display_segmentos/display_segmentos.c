/*
 * descripcion: programa de diagnostico para un display
 * de 7 segmentos de catodo comun
 *
 * enciende un solo segmento a la vez recorriendo
 * rb0, rb1, rb2... hasta rb7
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

void main(void)
{
    // deja los pines analogicos configurados como digitales
    ADCON1 = 0x06;

    // todo el puerto b sera salida
    TRISB = 0x00;

    // parte con todos los segmentos apagados
    PORTB = 0x00;

    // variable para recorrer rb0 hasta rb7
    unsigned char i;

    // el programa se repite para siempre
    while(1)
    {
        // recorre los 8 bits del puerto b
        for(i = 0; i < 8; i++)
        {
            // apaga todos los segmentos
            PORTB = 0x00;

            // enciende solamente el pin rb correspondiente
            PORTB = (1 << i);

            // espera 1 segundo
            __delay_ms(1000);
        }
    }

    return;
}