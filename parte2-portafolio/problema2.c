#include <stdio.h>

int main()
{
    int num1, num2, num3, num4;
    int suma;
    int producto;

    printf("Ingrese el primer numero: ");
    scanf("%d", &num1);

    printf("Ingrese el segundo numero: ");
    scanf("%d", &num2);

    printf("Ingrese el tercer numero: ");
    scanf("%d", &num3);

    printf("Ingrese el cuarto numero: ");
    scanf("%d", &num4);

    suma = num1 + num2;
    producto = num3 * num4;

    printf("La suma de los dos primeros es: %d\n", suma);
    printf("El producto del tercero y cuarto es: %d\n", producto);

    return 0;
}