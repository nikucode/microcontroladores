/*
 * descripcion: programa basico para encender un led conectado
 * al pin rb0 del pic16f877a
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

// frecuencia del cristal de 4 mhz
#define _XTAL_FREQ 4000000

// nombre que usaremos para el pin rb0
#define LED RB0

void main(void)
{
    // configura todo el puerto b como salida
    TRISB = 0x00;

    // deja todas las salidas del puerto b apagadas al iniciar
    PORTB = 0x00;

    // el programa se repite para siempre
    while (1)
    {
        // enciende el led
        LED = 1;

        // espera 500 milisegundos
        __delay_ms(500);

        // apaga el led
        LED = 0;

        // espera otros 500 milisegundos
        __delay_ms(500);
    }

    return;
}