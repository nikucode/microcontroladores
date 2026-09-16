#include <stdio.h>

int main()
{
    // Creamos una variable para guardar el numero
    int x;

    // Pedimos ingresar un numero de hasta tres digitos
    printf("Ingrese un numero de 1, 2 o 3 digitos: ");
    scanf("%d", &x);

    // Si esta entre 1 y 9, tiene un digito
    if (x >= 1 && x <= 9)
    {
        printf("El numero tiene un digito\n");
    }

    // Si esta entre 10 y 99, tiene dos digitos
    else if (x >= 10 && x <= 99)
    {
        printf("El numero tiene dos digitos\n");
    }

    // Si esta entre 100 y 999, tiene tres digitos
    else if (x >= 100 && x <= 999)
    {
        printf("El numero tiene tres digitos\n");
    }

    // Si es 1000 o mayor, supera los tres digitos
    else if (x >= 1000)
    {
        printf("Error: el numero supera los tres digitos\n");
    }

    // Si llegamos hasta aca, no se ingreso un entero positivo
    else
    {
        printf("Error: debe ingresar un numero positivo\n");
    }

    return 0;
}