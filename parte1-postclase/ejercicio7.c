// Realizar un programa que solicite al operador ingresar dos números 
// y muestre por pantalla el mayor de ellos.

#include <stdio.h>

int main()
{
    float n1, n2;

    printf("Ingrese el primer valor: ");
    scanf("%f", &n1);

    printf("Ingrese el segundo valor: ");
    scanf("%f", &n2);

    if (n1>n2)
    { 
        printf("El mayor de los dos valores es: %.2f", n1);

    }
    else if (n2>n1)
    {
        printf("El mayor de los dos valores es: %.2f", n2);
    }
    else
    {
        printf("Los dos valores son iguales: %.2f", n1);
    }

    return 0;
}