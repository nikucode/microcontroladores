// Se ingresa la cantidad total de preguntas y la cantidad de preguntas
// contestadas correctamente, luego calculamos el porcentaje de respuestas
// correctas y mostramos el nivel obtenido

#include <stdio.h>

int main()
{
    // Guardamos la cantidad total de preguntas y las respuestas correctas
    int total, correctas;

    // Usamos float porque el porcentaje puede tener decimales
    float porcentaje;

    // Pedimos la cantidad total de preguntas
    printf("Ingrese la cantidad total de preguntas: ");
    scanf("%d", &total);

    // Pedimos la cantidad de respuestas correctas
    printf("Ingrese la cantidad de respuestas correctas: ");
    scanf("%d", &correctas);

    // Calculamos el porcentaje de respuestas correctas
    // Multiplicamos por 100 y dividimos por el total de preguntas
    porcentaje = (correctas * 100.0) / total;

    // Mostramos el porcentaje obtenido
    printf("El porcentaje de respuestas correctas es: %.2f%%\n", porcentaje);

    // Si el porcentaje es mayor o igual a 90, tiene nivel maximo
    if (porcentaje >= 90)
    {
        printf("Nivel maximo\n");
    }

    // Si no llego a 90, pero es mayor o igual a 75, tiene nivel medio
    else if (porcentaje >= 75)
    {
        printf("Nivel medio\n");
    }

    // Si no llego a 75, pero es mayor o igual a 50, tiene nivel regular
    else if (porcentaje >= 50)
    {
        printf("Nivel regular\n");
    }

    // Si no se cumplio ninguna condicion anterior, tiene menos de 50
    else
    {
        printf("Fuera de nivel\n");
    }

    return 0;
}