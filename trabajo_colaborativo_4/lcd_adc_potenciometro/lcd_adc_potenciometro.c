/*
 * File:   lcd_adc_potenciometro.c
 * Author: minimodecoro
 *
 * descripcion:
 * lee una entrada analogica desde ra0/an0 utilizando
 * el adc del pic16f877a.
 *
 * para la simulacion se usa un potenciometro de 10k
 * conectado entre 5v y gnd, con el cursor conectado
 * a ra0.
 *
 * el lcd muestra:
 *
 * adc: valor entre 0 y 1023
 * mv: voltaje equivalente entre 0 y 5000 mv
 *
 * conexiones lcd:
 *
 * rs  -> rd2
 * e   -> rd3
 * rw  -> gnd
 * d4  -> rd4
 * d5  -> rd5
 * d6  -> rd6
 * d7  -> rd7
 *
 * conexiones potenciometro:
 *
 * terminal 1 -> +5v
 * cursor     -> ra0 / an0
 * terminal 3 -> gnd
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


// pines de control del lcd
#define LCD_RS PORTDbits.RD2
#define LCD_EN PORTDbits.RD3


// genera el pulso de enable
void LCD_Pulso(void)
{
    LCD_EN = 1;
    __delay_us(50);

    LCD_EN = 0;
    __delay_us(50);
}


// envia 4 bits al lcd usando rd4-rd7
void LCD_EnviarNibble(unsigned char nibble)
{
    // limpia solamente rd4-rd7
    PORTD &= 0x0F;

    // coloca el nibble en la parte alta de portd
    PORTD |= (nibble << 4);

    LCD_Pulso();
}


// envia un comando al lcd
void LCD_Comando(unsigned char comando)
{
    // rs = 0 significa comando
    LCD_RS = 0;

    // envia primero los 4 bits superiores
    LCD_EnviarNibble(comando >> 4);

    // luego envia los 4 bits inferiores
    LCD_EnviarNibble(comando & 0x0F);

    __delay_ms(2);
}


// envia un caracter al lcd
void LCD_Dato(unsigned char dato)
{
    // rs = 1 significa dato
    LCD_RS = 1;

    LCD_EnviarNibble(dato >> 4);
    LCD_EnviarNibble(dato & 0x0F);

    __delay_ms(2);
}


// inicializa el lcd
void LCD_Inicializar(void)
{
    // espera a que el lcd encienda correctamente
    __delay_ms(20);

    // secuencia de inicio para modo de 4 bits
    LCD_EnviarNibble(0x03);
    __delay_ms(5);

    LCD_EnviarNibble(0x03);
    __delay_ms(5);

    LCD_EnviarNibble(0x03);
    __delay_ms(5);

    LCD_EnviarNibble(0x02);

    // modo 4 bits, 2 lineas, caracteres 5x8
    LCD_Comando(0x28);

    // display encendido, cursor apagado
    LCD_Comando(0x0C);

    // cursor avanza automaticamente
    LCD_Comando(0x06);

    // limpia la pantalla
    LCD_Comando(0x01);

    __delay_ms(2);
}


// escribe una cadena de texto completa
void LCD_EscribirTexto(const char *texto)
{
    while(*texto != '\0')
    {
        LCD_Dato(*texto);
        texto++;
    }
}


// escribe un numero entero entre 0 y 9999
void LCD_EscribirNumero(unsigned int numero)
{
    unsigned char miles;
    unsigned char centenas;
    unsigned char decenas;
    unsigned char unidades;

    miles = numero / 1000;
    centenas = (numero / 100) % 10;
    decenas = (numero / 10) % 10;
    unidades = numero % 10;

    // evita mostrar ceros innecesarios al principio
    if(miles > 0)
    {
        LCD_Dato(miles + '0');
    }

    if(miles > 0 || centenas > 0)
    {
        LCD_Dato(centenas + '0');
    }

    LCD_Dato(decenas + '0');
    LCD_Dato(unidades + '0');
}


// configura el modulo adc
void ADC_Inicializar(void)
{
    /*
     * adcon1 = 0x8e
     *
     * resultado justificado a la derecha
     * an0 queda como entrada analogica
     * los otros canales quedan digitales
     * vref+ = vdd
     * vref- = vss
     */
    ADCON1 = 0x8E;

    /*
     * adcon0 = 0x41
     *
     * selecciona an0
     * reloj de conversion fosc/8
     * enciende el modulo adc
     */
    ADCON0 = 0x41;
}


// realiza una lectura del adc
unsigned int ADC_Leer(void)
{
    // tiempo para que se estabilice la señal analogica
    __delay_us(20);

    // inicia la conversion
    ADCON0bits.GO = 1;

    // espera hasta que termine la conversion
    while(ADCON0bits.GO == 1)
    {
        // solo espera
    }

    // combina adresh y adresl para obtener el valor de 10 bits
    return ((unsigned int)(ADRESH) << 8) | ADRESL;
}


void main(void)
{
    unsigned int valorADC;
    unsigned long milivoltios;

    // portd completo como salida para el lcd
    TRISD = 0x00;

    // ra0 como entrada analogica
    TRISAbits.TRISA0 = 1;

    // inicializa adc y lcd
    ADC_Inicializar();
    LCD_Inicializar();

    while(1)
    {
        // lee el valor entre 0 y 1023
        valorADC = ADC_Leer();

        /*
         * convierte el valor adc a milivoltios
         *
         * 0    -> 0 mv
         * 1023 -> 5000 mv
         */
        milivoltios = ((unsigned long)valorADC * 5000) / 1023;


        // primera linea del lcd
        LCD_Comando(0x80);

        LCD_EscribirTexto("ADC: ");
        LCD_EscribirNumero(valorADC);

        // espacios para borrar residuos de valores anteriores
        LCD_EscribirTexto("   ");


        // segunda linea del lcd
        LCD_Comando(0xC0);

        LCD_EscribirTexto("mV: ");
        LCD_EscribirNumero((unsigned int)milivoltios);

        LCD_EscribirTexto("   ");


        // actualiza aproximadamente 3 veces por segundo
        __delay_ms(300);
    }

    return;
}