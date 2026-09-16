#include <stdio.h>

int main()
{
    float num1, num2, num3, num4;
    float suma;
    float promedio;

    printf("Ingrese el primer numero: ");
    scanf("%f", &num1);

    printf("Ingrese el segundo numero: ");
    scanf("%f", &num2);

    printf("Ingrese el tercer numero: ");
    scanf("%f", &num3);

    printf("Ingrese el cuarto numero: ");
    scanf("%f", &num4);

    suma = num1 + num2 + num3 + num4;
    promedio = suma / 4;

    printf("La suma es: %.2f\n", suma);
    printf("El promedio es: %.2f\n", promedio);

    return 0;
}