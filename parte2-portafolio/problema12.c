// Se ingresan por teclado tres números, si al menos uno de los valores
// ingresados es menor a 10, imprimir en pantalla la leyenda
// "Alguno de los números es menor a diez".

#include <stdio.h>

int main()
{
    // Variables donde guardaremos los tres números ingresados.
    int n1, n2, n3;

    // Pedimos y guardamos el primer número.
    printf("Ingrese el primer número: ");
    scanf("%d", &n1);

    // Pedimos y guardamos el segundo número.
    printf("Ingrese el segundo número: ");
    scanf("%d", &n2);

    // Pedimos y guardamos el tercer número.
    printf("Ingrese el tercer número: ");
    scanf("%d", &n3);

    // || significa "O".
    // Basta con que UNA de estas tres condiciones sea verdadera
    // para que se ejecute el printf.
    if (n1 < 10 || n2 < 10 || n3 < 10)
    {
        printf("Alguno de los números es menor a diez\n");
    }

    return 0;
}