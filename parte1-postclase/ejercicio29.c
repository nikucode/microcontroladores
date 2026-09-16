// Desarrollar un programa que solicite la carga de 10 números enteros
// e imprima únicamente la suma de los últimos 5 valores ingresados (es decir,
// los valores del 6° al 10°).

#include <stdio.h>

int main()
{
    // Inicializamos un arreglo para almacenar los 10 números ingresados
    int numeros[10];
    int suma = 0;

    // Solicitamos al usuario que ingrese 10 números enteros
    printf("Ingrese 10 números enteros:\n");
    for (int i = 0; i < 10; i++)
    {
        printf("Número %d: ", i + 1);
        scanf("%d", &numeros[i]);
    }

    // Calculamos la suma de los últimos 5 valores ingresados (del índice 5 al 9)
    for (int i = 5; i < 10; i++)
    {
        suma += numeros[i];
    }

    // Mostramos el resultado de la suma
    printf("La suma de los últimos 5 valores ingresados es: %d\n", suma);

    return 0;
}