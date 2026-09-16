#include <stdio.h>

int main()
{
    float num1, num2;
    float suma, diferencia;
    float producto, division;

    printf("Ingrese el primer numero: ");
    scanf("%f", &num1);

    printf("Ingrese el segundo numero: ");
    scanf("%f", &num2);

    if (num1 > num2)
    {
        suma = num1 + num2;
        diferencia = num1 - num2;

        printf("La suma es: %.2f\n", suma);
        printf("La diferencia es: %.2f\n", diferencia);
    }
    else
    {
        producto = num1 * num2;
        division = num1 / num2;

        printf("El producto es: %.2f\n", producto);
        printf("La division es: %.2f\n", division);
    }

    return 0;
}