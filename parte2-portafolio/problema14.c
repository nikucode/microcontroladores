// Una planta tiene un lote de n piezas y se debe ingresar
// la longitud de cada una.
// Contar cuántas piezas tienen una longitud entre 1.20 y 1.30 metros.

#include <stdio.h>

int main()
{
    // n guarda la cantidad de piezas que vamos a revisar
    // aptas va contando cuántas piezas cumplen con el rango
    int n, aptas = 0;

    // Usamos float porque la longitud puede tener decimales
    float longitud;

    // Primero preguntamos cuántas piezas tiene el lote
    printf("Ingrese la cantidad de piezas a procesar: ");
    scanf("%d", &n);

    // Repetimos el proceso una vez por cada pieza
    for (int i = 1; i <= n; i++)
    {
        // Pedimos la longitud de la pieza actual
        printf("Ingrese la longitud de la pieza %d: ", i);
        scanf("%f", &longitud);

        // La pieza es apta si su longitud es mayor o igual a 1.20
        // y al mismo tiempo es menor o igual a 1.30
        if (longitud >= 1.20 && longitud <= 1.30)
        {
            // Si cumple la condición, aumentamos el contador en 1
            aptas++;
        }
    }

    // Al terminar de revisar todas las piezas,
    // mostramos cuántas resultaron aptas
    printf("La cantidad de piezas aptas es: %d\n", aptas);

    return 0;
}