/*
 * File:   display_contador.c
 * Author: minimodecoro
 *
 * Created on September 29, 2026, 9:24 PM
 */


/*
 * descripcion: contador de 0 a 9 en display de 7 segmentos
 * de catodo comun
 *
 * conexiones usadas en simulide:
 *
 * rb0 -> a
 * rb1 -> b
 * rb2 -> c
 * rb3 -> d
 * rb4 -> e
 * rb5 -> f
 * rb6 -> g
 * rb7 -> dp
 *
 * cada vez que se presiona el pulsador conectado a ra0
 * el display avanza al siguiente numero
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

#include <xc.h>

#define _XTAL_FREQ 4000000

// pulsador conectado a ra0
#define PULSADOR RA0

/*
 * tabla para display de 7 segmentos de catodo comun
 *
 * mapeo:
 * rb0 = a
 * rb1 = b
 * rb2 = c
 * rb3 = d
 * rb4 = e
 * rb5 = f
 * rb6 = g
 * rb7 = dp
 *
 * en catodo comun:
 * 1 = segmento encendido
 * 0 = segmento apagado
 */

const unsigned char display[10] = {
    0x3F, // 0
    0x06, // 1
    0x5B, // 2
    0x4F, // 3
    0x66, // 4
    0x6D, // 5
    0x7D, // 6
    0x07, // 7
    0x7F, // 8
    0x6F  // 9
};

void main(void)
{
    // variable que guarda el numero actual
    unsigned char contador = 0;

    // deja los pines analogicos como digitales
    ADCON1 = 0x06;

    // portb completo como salida para el display
    TRISB = 0x00;

    // ra0 como entrada para el pulsador
    TRISAbits.TRISA0 = 1;

    // muestra inicialmente el numero 0
    PORTB = display[contador];

    while(1)
    {
        // con pull-up:
        // boton suelto = 1
        // boton presionado = 0
        if(PULSADOR == 0)
        {
            // espera corta para evitar rebotes
            __delay_ms(20);

            // confirma que el boton sigue presionado
            if(PULSADOR == 0)
            {
                // avanza al siguiente numero
                contador++;

                // despues del 9 vuelve al 0
                if(contador == 10)
                {
                    contador = 0;
                }

                // actualiza el numero mostrado
                PORTB = display[contador];

                // espera hasta que se suelte el boton
                while(PULSADOR == 0)
                {
                    // solo espera
                }

                // pequeña espera despues de soltar
                __delay_ms(20);
            }
        }
    }

    return;
}