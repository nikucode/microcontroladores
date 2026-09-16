#include <stdio.h>

int main()
{
    int n, f;
    int equilateros = 0;
    int isosceles = 0;
    int escalenos = 0;

    float lado1, lado2, lado3;

    printf("Ingrese la cantidad de triangulos: ");
    scanf("%d", &n);

    for (f = 1; f <= n; f++)
    {
        printf("\nTriangulo %d\n", f);

        printf("Ingrese el primer lado: ");
        scanf("%f", &lado1);

        printf("Ingrese el segundo lado: ");
        scanf("%f", &lado2);

        printf("Ingrese el tercer lado: ");
        scanf("%f", &lado3);

        if (lado1 == lado2 && lado2 == lado3)
        {
            printf("El triangulo es equilatero\n");
            equilateros = equilateros + 1;
        }
        else if (lado1 == lado2 || lado1 == lado3 || lado2 == lado3)
        {
            printf("El triangulo es isosceles\n");
            isosceles = isosceles + 1;
        }
        else
        {
            printf("El triangulo es escaleno\n");
            escalenos = escalenos + 1;
        }
    }

    printf("\nCantidad de equilateros: %d\n", equilateros);
    printf("Cantidad de isosceles: %d\n", isosceles);
    printf("Cantidad de escalenos: %d\n", escalenos);

    if (equilateros <= isosceles && equilateros <= escalenos)
    {
        printf("El tipo con menor cantidad es: equilateros\n");
    }
    else if (isosceles <= equilateros && isosceles <= escalenos)
    {
        printf("El tipo con menor cantidad es: isosceles\n");
    }
    else
    {
        printf("El tipo con menor cantidad es: escalenos\n");
    }

    return 0;
}