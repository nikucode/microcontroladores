#include <stdio.h>

int main()
{
    int f;
    int valor;

    int negativos = 0;
    int positivos = 0;
    int multiplos_15 = 0;
    int suma_pares = 0;

    for (f = 1; f <= 10; f++)
    {
        printf("Ingrese el valor %d: ", f);
        scanf("%d", &valor);

        if (valor < 0)
        {
            negativos = negativos + 1;
        }

        if (valor > 0)
        {
            positivos = positivos + 1;
        }

        if (valor % 15 == 0)
        {
            multiplos_15 = multiplos_15 + 1;
        }

        if (valor % 2 == 0)
        {
            suma_pares = suma_pares + valor;
        }
    }

    printf("\nCantidad de valores negativos: %d\n", negativos);
    printf("Cantidad de valores positivos: %d\n", positivos);
    printf("Cantidad de multiplos de 15: %d\n", multiplos_15);
    printf("Suma de los valores pares: %d\n", suma_pares);

    return 0;
}