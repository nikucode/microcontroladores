// Desarrollar un programa que muestre la tabla de multiplicar del 5 (del5 al 50)

#include <stdio.h>

int main()
{
    // Inicializamos la variable para el múltiplo de 5
    int multiplo = 5;

    // Imprimimos la tabla de multiplicar del 5 desde 5 hasta 50
    while (multiplo <= 50)
    {
        printf("%d ", multiplo);
        multiplo += 5; // Incrementamos al siguiente múltiplo de 5
    }

    printf("\n"); // Salto de línea al final

    return 0;
}