#include <stdio.h>

int main()
{
    int numero;
    int f;

    printf("Ingrese un numero entre 1 y 10: ");
    scanf("%d", &numero);

    for (f = 1; f <= 12; f++)
    {
        printf("%d x %d = %d\n", numero, f, numero * f);
    }

    return 0;
}