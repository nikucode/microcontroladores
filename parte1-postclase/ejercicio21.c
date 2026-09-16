//  Realizar un programa que imprima 25 términos de la serie 11 - 22 -
// 33 - 44, etc. (No se ingresan valores por teclado)

#include <stdio.h>

int main()
{
    // Inicializamos la variable para el término de la serie
    int termino = 11;

    // Imprimimos los 25 términos de la serie
    for (int i = 0; i < 25; i++)
    {
        printf("%d ", termino);
        termino += 11; // Incrementamos el término en 11 para el siguiente
    }

    printf("\n"); // Salto de línea al final

    return 0;
}