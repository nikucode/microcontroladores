// Desarrollar un programa que permita la carga de 10 valores por
// teclado y nos muestre posteriormente la suma de los valores ingresados y su
// promedio. Este problema ya lo desarrollamos empleando el while, lo
// resolveremos empleando la estructura for.

#include <stdio.h>

int main()
{
    // Inicializamos un arreglo para almacenar los 10 valores ingresados
    int valores[10];
    int suma = 0;
    float promedio;

    // Solicitamos al usuario que ingrese 10 valores
    printf("Ingrese 10 valores:\n");
    for (int i = 0; i < 10; i++)
    {
        printf("Valor %d: ", i + 1);
        scanf("%d", &valores[i]);
        suma += valores[i]; // Acumulamos la suma de los valores ingresados
    }

    // Calculamos el promedio
    promedio = suma / 10.0;

    // Mostramos la suma y el promedio de los valores ingresados
    printf("La suma de los valores ingresados es: %d\n", suma);
    printf("El promedio de los valores ingresados es: %.2f\n", promedio);

    return 0;
}