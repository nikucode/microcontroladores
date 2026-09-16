#include <stdio.h>

int main()
{
    float precio;
    int cantidad;
    float total;

    printf("Ingrese el precio del articulo: ");
    scanf("%f", &precio);

    printf("Ingrese la cantidad: ");
    scanf("%d", &cantidad);

    total = precio * cantidad;

    printf("El total a pagar es: %.2f\n", total);

    return 0;
}