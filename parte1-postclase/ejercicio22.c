// Realizar un programa que permita cargar dos listas de 15 valores cada
// una. Informar con un mensaje cuál de las dos listas tiene un valor acumulado
// mayor (mensajes "Lista 1 mayor", "Lista 2 mayor", "Listas iguales")
// Importante: un algoritmo puede contener dos o más estructuras repetitivas
// (while) en secuencia. En este problema se usan dos bucles independientes,
// uno por lista.

#include <stdio.h>

int main()
{
    // Inicializamos las variables para las listas y sus acumulados
    int lista1[15], lista2[15];
    int acumulado1 = 0, acumulado2 = 0;

    // Cargamos la primera lista
    printf("Ingrese 15 valores para la Lista 1:\n");
    for (int i = 0; i < 15; i++)
    {
        printf("Valor %d: ", i + 1);
        scanf("%d", &lista1[i]);
        acumulado1 += lista1[i]; // Acumulamos el valor ingresado
    }

    // Cargamos la segunda lista
    printf("Ingrese 15 valores para la Lista 2:\n");
    for (int i = 0; i < 15; i++)
    {
        printf("Valor %d: ", i + 1);
        scanf("%d", &lista2[i]);
        acumulado2 += lista2[i]; // Acumulamos el valor ingresado
    }

    // Comparamos los acumulados y mostramos el resultado
    if (acumulado1 > acumulado2)
    {
        printf("Lista 1 mayor\n");
    }
    else if (acumulado2 > acumulado1)
    {
        printf("Lista 2 mayor\n");
    }
    else
    {
        printf("Listas iguales\n");
    }

    return 0;
}