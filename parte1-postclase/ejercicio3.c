// Realizar un diagrama de flujo y programa que determine la superficie
//de un cuadrado, solicitando el ingreso de un lado.


#include <stdio.h>

int main() 
{
    float lado, superficie;

    printf("Ingrese el valor del lado del cuadrado: ");
    scanf("%f", &lado);
    
    superficie = lado * lado;
    printf("La superficie del cuadrado es: %.2f", superficie);
    
    return 0;
}

