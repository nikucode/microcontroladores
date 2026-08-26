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
