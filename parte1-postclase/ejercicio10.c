// Realizar un programa que determine si un numero es par o no.

#include <stdio.h>

int main()
{
    // Creamos una variable para guardar el numero ingresado
    int numero;

    // Pedimos al usuario que ingrese un numero entero
    printf("Ingrese un numero entero: ");
    scanf("%d", &numero);

    // El operador % obtiene el resto de una division
    // Si al dividir el numero por 2 el resto es 0, entonces es par
    if (numero % 2 == 0)
    {
        printf("El numero es par.\n");
    }

    // Si la condicion anterior no se cumple, entonces es impar
    else
    {
        printf("El numero es impar.\n");
    }

    return 0;
}