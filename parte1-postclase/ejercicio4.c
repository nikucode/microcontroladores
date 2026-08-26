#include <stdio.h>

int main() 
{
    float n1, n2, suma, producto;
    printf("Ingrese el primer valor: ");
    scanf("%f", &n1);

    printf("Ingrese el segundo valor: ");
    scanf("%f", &n2);

    suma = n1 + n2;
    producto = n1 * n2;

    printf("La suma de los dos valores es: %.2f\n", suma);
    printf("El producto de los dos valores es: %.2f\n", producto);

    return 0;
}