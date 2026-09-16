// Se ingresan por teclado las alturas (en metros) de n personas.
// Calcular y mostrar la altura promedio del grupo

#include <stdio.h>

int main()
{
    int n;
    float altura, suma = 0.0, promedio;

    // Pedimos al usuario que ingrese la cantidad de personas
    printf("Ingrese la cantidad de personas: ");
    scanf("%d", &n);

    // Validamos que n sea mayor a 0
    if (n <= 0)
    {
        printf("La cantidad de personas debe ser mayor a 0.\n");
        return 1; // Salimos del programa con error
    }

    // Cargamos las alturas y calculamos la suma
    for (int i = 0; i < n; i++)
    {
        printf("Ingrese la altura de la persona %d (en metros): ", i + 1);
        scanf("%f", &altura);
        suma += altura; // Acumulamos la altura ingresada
    }

    // Calculamos el promedio
    promedio = suma / n;

    // Mostramos el resultado
    printf("La altura promedio del grupo es: %.2f metros\n", promedio);

    return 0;
}