#include <stdio.h>

int main()
{
    int n, f;
    int x, y;

    int cuadrante1 = 0;
    int cuadrante2 = 0;
    int cuadrante3 = 0;
    int cuadrante4 = 0;

    printf("Ingrese la cantidad de puntos: ");
    scanf("%d", &n);

    for (f = 1; f <= n; f++)
    {
        printf("\nPunto %d\n", f);

        printf("Ingrese x: ");
        scanf("%d", &x);

        printf("Ingrese y: ");
        scanf("%d", &y);

        if (x > 0 && y > 0)
        {
            cuadrante1 = cuadrante1 + 1;
        }
        else if (x < 0 && y > 0)
        {
            cuadrante2 = cuadrante2 + 1;
        }
        else if (x < 0 && y < 0)
        {
            cuadrante3 = cuadrante3 + 1;
        }
        else if (x > 0 && y < 0)
        {
            cuadrante4 = cuadrante4 + 1;
        }
    }

    printf("\nPuntos en el primer cuadrante: %d\n", cuadrante1);
    printf("Puntos en el segundo cuadrante: %d\n", cuadrante2);
    printf("Puntos en el tercer cuadrante: %d\n", cuadrante3);
    printf("Puntos en el cuarto cuadrante: %d\n", cuadrante4);

    return 0;
}