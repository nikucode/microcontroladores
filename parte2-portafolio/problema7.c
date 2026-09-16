#include <stdio.h>

int main()
{
    int numero;

    printf("Ingrese un numero entero positivo: ");
    scanf("%d", &numero);

    if (numero >= 10 && numero <= 99)
    {
        printf("El numero tiene dos digitos\n");
    }
    else
    {
        printf("El numero tiene un digito\n");
    }

    return 0;
}