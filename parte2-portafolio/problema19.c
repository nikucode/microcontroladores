#include <stdio.h>

int main()
{
    int f;
    int edad;
    
    int suma_manana = 0;
    int suma_tarde = 0;
    int suma_noche = 0;

    float promedio_manana;
    float promedio_tarde;
    float promedio_noche;

    printf("=== TURNO MANANA ===\n");

    for (f = 1; f <= 5; f++)
    {
        printf("Ingrese edad del estudiante %d: ", f);
        scanf("%d", &edad);

        suma_manana = suma_manana + edad;
    }

    printf("\n=== TURNO TARDE ===\n");

    for (f = 1; f <= 6; f++)
    {
        printf("Ingrese edad del estudiante %d: ", f);
        scanf("%d", &edad);

        suma_tarde = suma_tarde + edad;
    }

    printf("\n=== TURNO NOCHE ===\n");

    for (f = 1; f <= 11; f++)
    {
        printf("Ingrese edad del estudiante %d: ", f);
        scanf("%d", &edad);

        suma_noche = suma_noche + edad;
    }

    promedio_manana = (float)suma_manana / 5;
    promedio_tarde = (float)suma_tarde / 6;
    promedio_noche = (float)suma_noche / 11;

    printf("\nPromedio turno manana: %.2f\n", promedio_manana);
    printf("Promedio turno tarde: %.2f\n", promedio_tarde);
    printf("Promedio turno noche: %.2f\n", promedio_noche);

    if (promedio_manana <= promedio_tarde &&
        promedio_manana <= promedio_noche)
    {
        printf("El turno con menor promedio es: manana\n");
    }
    else if (promedio_tarde <= promedio_manana &&
             promedio_tarde <= promedio_noche)
    {
        printf("El turno con menor promedio es: tarde\n");
    }
    else
    {
        printf("El turno con menor promedio es: noche\n");
    }

    return 0;
}