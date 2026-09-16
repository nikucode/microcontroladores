#include <stdio.h>

int main()
{
    float lado;
    float perimetro;

    printf("Ingrese el lado del cuadrado: ");
    scanf("%f", &lado);

    perimetro = lado * 4;

    printf("El perimetro es: %.2f\n", perimetro);

    return 0;
}