// Desarrollar un programa que permita cargar n números enteros y
// luego nos informe cuántos valores fueron pares y cuántos impares.
// Emplear el operador “%” en la condición de la estructura condicional (este
// operador retorna el resto de la división de dos valores, por ejemplo 11%2
// retorna un 1):
// if (valor%2==0) //Si el if da verdadero luego es par.

#include <stdio.h>

int main()
{
    int n, valor;
    int pares = 0, impares = 0;

    // Pedimos al usuario que ingrese la cantidad de números a cargar
    printf("Ingrese la cantidad de números a cargar: ");
    scanf("%d", &n);

    // Cargamos los n números y contamos pares e impares
    for (int i = 0; i < n; i++)
    {
        printf("Ingrese el número %d: ", i + 1);
        scanf("%d", &valor);

        // Verificamos si el número es par o impar
        if (valor % 2 == 0)
        {
            pares++; // Incrementamos el contador de pares
        }
        else
        {
            impares++; // Incrementamos el contador de impares
        }
    }

    // Mostramos los resultados
    printf("Cantidad de números pares: %d\n", pares);
    printf("Cantidad de números impares: %d\n", impares);

    return 0;
}