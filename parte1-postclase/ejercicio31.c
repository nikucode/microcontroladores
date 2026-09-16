// Escribir un programa que lea 10 números enteros y luego muestre
// cuántos valores ingresados fueron múltiplos de 3 y cuántos de 5. Debemos
// tener en cuenta que hay números que son múltiplos de 3 y de 5 a la vez.

#include <stdio.h>

int main()
{
    // Inicializamos un arreglo para almacenar los 10 números ingresados
    int numeros[10];
    int multiplosDe3 = 0, multiplosDe5 = 0;

    // Solicitamos al usuario que ingrese 10 números enteros
    printf("Ingrese 10 números enteros:\n");
    for (int i = 0; i < 10; i++)
    {
        printf("Número %d: ", i + 1);
        scanf("%d", &numeros[i]);
    }

    // Contamos cuántos números son múltiplos de 3 y cuántos de 5
    for (int i = 0; i < 10; i++)
    {
        if (numeros[i] % 3 == 0)
        {
            multiplosDe3++;
        }
        if (numeros[i] % 5 == 0)
        {
            multiplosDe5++;
        }
    }

    // Mostramos los resultados
    printf("Cantidad de múltiplos de 3: %d\n", multiplosDe3);
    printf("Cantidad de múltiplos de 5: %d\n", multiplosDe5);

    return 0;
}