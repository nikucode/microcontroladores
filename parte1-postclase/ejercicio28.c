// Se ingresa la cantidad de valores y se leen n números enteros,
// luego contamos cuántos de ellos son mayores o iguales a 1000
// y mostramos el resultado

#include <stdio.h>

int main()
{
    // Guardamos la cantidad de valores a ingresar
    int n;

    // Guardamos el valor que se lee en cada iteración
    int valor;

    // Contador de valores mayores o iguales a 1000
    int cantidad = 0;

    // Pedimos la cantidad de valores que se van a ingresar
    printf("Cuantos valores ingresará: ");
    scanf("%d", &n);

    // Recorremos n veces para leer cada valor
    for (int i = 0; i < n; i++)
    {
        // Pedimos el valor al usuario
        printf("Ingrese el valor: ");
        scanf("%d", &valor);

        // Si el valor es mayor o igual a 1000, incrementamos el contador
        if (valor >= 1000)
        {
            cantidad++;
        }
    }

    // Mostramos la cantidad de valores que cumplen la condición
    printf("La cantidad de valores mayores o iguales a 1000 son: %d\n", cantidad);

    return 0;
}   