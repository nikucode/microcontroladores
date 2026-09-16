// Escribir un programa que pida ingresar la coordenada de un punto
// en el plano, es decir dos valores enteros x e y (distintos a cero).

#include <stdio.h>

int main()
{
    // Variables donde se guardan las coordenadas del punto
    int x, y;

    // Pedimos la coordenada x
    printf("Ingrese la coordenada x: ");
    scanf("%d", &x);

    // Pedimos la coordenada y
    printf("Ingrese la coordenada y: ");
    scanf("%d", &y);

    // Si x es positivo y también y es positivo,
    // entonces el punto está en el primer cuadrante
    if (x > 0 && y > 0)
    {
        printf("El punto está en el primer cuadrante.\n");
    }

    // Si x es negativo pero y es positivo,
    // entonces está en el segundo cuadrante
    else if (x < 0 && y > 0)
    {
        printf("El punto está en el segundo cuadrante.\n");
    }

    // Si tanto x como y son negativos,
    // entonces está en el tercer cuadrante
    else if (x < 0 && y < 0)
    {
        printf("El punto está en el tercer cuadrante.\n");
    }

    // Si x es positivo pero y es negativo,
    // entonces está en el cuarto cuadrante
    else if (x > 0 && y < 0)
    {
        printf("El punto está en el cuarto cuadrante.\n");
    }

    return 0;
}