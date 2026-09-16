// Solicitar el ingreso de 10 notas de alumnos.
// Contar cuántos tienen nota mayor o igual a 7
// y cuántos tienen nota menor a 7.

#include <stdio.h>

int main()
{
    // Guardamos aquí la nota de cada alumno
    int nota;

    // Estos contadores empiezan en 0 porque todavía
    // no hemos revisado ninguna nota
    int aprobados = 0;
    int reprobados = 0;

    // Repetimos el proceso 10 veces, una por cada alumno
    for (int i = 1; i <= 10; i++)
    {
        printf("Ingrese la nota del alumno %d: ", i);
        scanf("%d", &nota);

        // Si la nota es 7 o mayor, contamos un aprobado
        if (nota >= 7)
        {
            aprobados++;
        }
        // Si es menor que 7, contamos un reprobado
        else
        {
            reprobados++;
        }
    }

    // Después de revisar las 10 notas mostramos los resultados
    printf("\nCantidad de aprobados: %d\n", aprobados);
    printf("Cantidad de reprobados: %d\n", reprobados);

    return 0;
}