// Escribir un programa que, dados tres valores numéricos distintos,
// calcule e informe su rango de variación, mostrando el mayor y el menor de ellos.

#include <stdio.h>

int main()
{
    // Guardamos los tres valores ingresados por el usuario
    int valor1, valor2, valor3;

    // Pedimos al usuario que ingrese los tres valores
    printf("Ingrese el primer valor: ");
    scanf("%d", &valor1);
    printf("Ingrese el segundo valor: ");
    scanf("%d", &valor2);
    printf("Ingrese el tercer valor: ");
    scanf("%d", &valor3);

    // Inicializamos las variables para el mayor y menor valor
    int mayor = valor1;
    int menor = valor1;

    // Comparamos para encontrar el mayor
    if (valor2 > mayor)
        mayor = valor2;
    if (valor3 > mayor)
        mayor = valor3;

    // Comparamos para encontrar el menor
    if (valor2 < menor)
        menor = valor2;
    if (valor3 < menor)
        menor = valor3;

    // Mostramos los resultados
    printf("El mayor valor es: %d\n", mayor);
    printf("El menor valor es: %d\n", menor);

    return 0;
}
