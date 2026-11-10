/* Desafio PIC: PIC16F877A, 4 MHz, dos displays de catodo comun. */
#include <xc.h>

#pragma config FOSC = XT
#pragma config WDTE = OFF
#pragma config PWRTE = ON
#pragma config BOREN = ON
#pragma config LVP = OFF
#pragma config CPD = OFF
#pragma config WRT = OFF
#pragma config CP = OFF

#define _XTAL_FREQ 4000000UL

/* RD0..RD6 corresponden a los segmentos a..g. */
static const unsigned char digitos[10] = {
    0x3F, 0x06, 0x5B, 0x4F, 0x66,
    0x6D, 0x7D, 0x07, 0x7F, 0x6F
};

static void iniciar(void)
{
    PORTC = 0;
    PORTD = 0;
    TRISCbits.TRISC0 = 0; /* decenas */
    TRISCbits.TRISC1 = 0; /* unidades */
    TRISD = 0x00;
    TRISBbits.TRISB0 = 1; /* selector con pull-up externo */
    TRISAbits.TRISA0 = 1; /* LDR */
    TRISAbits.TRISA1 = 1; /* LM35 */

    CMCON = 0x07;  /* comparadores apagados */
    ADCON1 = 0x80; /* resultado a la derecha, VDD/VSS, AN0 y AN1 analogicos */
    ADCON0 = 0x41; /* ADC activo, AN0 inicial, Fosc/8 a 4 MHz */
}

static unsigned int leer_adc(unsigned char canal)
{
    ADCON0 = (unsigned char)((ADCON0 & 0xC7) | ((canal & 0x07) << 3));
    __delay_us(20); /* adquisicion tras seleccionar el canal */
    ADCON0 |= 0x04;
    while (ADCON0 & 0x04) { }
    return ((unsigned int)ADRESH << 8) | ADRESL;
}

static void mostrar(unsigned char numero)
{
    unsigned char decenas = numero / 10;
    unsigned char unidades = numero % 10;

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 0;
    PORTD = digitos[decenas];
    PORTCbits.RC0 = 1;
    __delay_ms(5);

    PORTCbits.RC0 = 0;
    PORTCbits.RC1 = 0;
    PORTD = digitos[unidades];
    PORTCbits.RC1 = 1;
    __delay_ms(5);

    PORTCbits.RC1 = 0;
}

void main(void)
{
    unsigned int adc;
    unsigned long valor;

    iniciar();
    while (1)
    {
        if (PORTBbits.RB0) /* interruptor abierto: LDR */
        {
            adc = leer_adc(0);
            /* Divisor de la guia: +5 V--10 kOhm--AN0--LDR--GND.
               Mas luz produce menos voltaje, por eso se invierte. */
            valor = 100UL - (((unsigned long)adc * 100UL + 511UL) / 1023UL);
        }
        else /* interruptor cerrado: LM35 */
        {
            adc = leer_adc(1);
            /* 10 mV/C con Vref = 5 V: 500 C a escala ADC completa. */
            valor = ((unsigned long)adc * 500UL + 511UL) / 1023UL;
        }

        if (valor > 99UL) valor = 99UL; /* solo dos digitos */
        mostrar((unsigned char)valor);
    }
}
