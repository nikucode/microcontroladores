// Mostrar por pantalla todos los múltiplos de 8 que existen desde 8 hasta 500 inclusive.
// Salida esperada en pantalla: 8 - 16 - 24 - 32 - ... - 496.

#include <stdio.h>

int main()
{
    // Inicializamos la variable para el múltiplo de 8
    int multiplo = 8;

    // Imprimimos los múltiplos de 8 desde 8 hasta 500 inclusive
    while (multiplo <= 500)
    {
        printf("%d", multiplo);
        if (multiplo + 8 <= 500) // Verificamos si hay un siguiente múltiplo dentro del rango
        {
            printf(" - "); // Imprimimos el separador si hay un siguiente múltiplo
        }
        multiplo += 8; // Incrementamos al siguiente múltiplo de 8
    }

    printf("\n"); // Salto de línea al final

    return 0;
}