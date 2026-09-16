#include <stdio.h>

int main()
{
    int n, f;
    int mayores_12 = 0;

    float base;
    float altura;
    float superficie;

    printf("Ingrese la cantidad de triangulos: ");
    scanf("%d", &n);

    for (f = 1; f <= n; f++)
    {
        printf("\nTriangulo %d\n", f);

        printf("Ingrese la base: ");
        scanf("%f", &base);

        printf("Ingrese la altura: ");
        scanf("%f", &altura);

        superficie = (base * altura) / 2;

        printf("Base: %.2f\n", base);
        printf("Altura: %.2f\n", altura);
        printf("Superficie: %.2f\n", superficie);

        if (superficie > 12)
        {
            mayores_12 = mayores_12 + 1;
        }
    }

    printf("\nCantidad de triangulos con superficie mayor a 12: %d\n",
           mayores_12);

    return 0;
}