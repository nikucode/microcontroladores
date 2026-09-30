/*
 * File:   lcd_mensaje.c
 * Author: minimodecoro
 *
 * descripcion: muestra un mensaje en un lcd 16x2
 * hd44780 usando modo de 4 bits
 *
 * conexiones:
 *
 * rs -> rd2
 * e  -> rd3
 * rw -> gnd
 * d4 -> rd4
 * d5 -> rd5
 * d6 -> rd6
 * d7 -> rd7
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

// genera un pulso en enable
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

void main(void)
{
    // deja los pines analogicos como digitales
    ADCON1 = 0x06;

    // portd completo como salida para el lcd
    TRISD = 0x00;

    // inicializa el lcd
    LCD_Inicializar();

    // mensaje que se mostrara en pantalla
    LCD_EscribirTexto("  Holii UWU >_< ");

    while(1)
    {
        // el mensaje queda fijo
    }

    return;
}