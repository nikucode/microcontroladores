// Se ingresan por teclado tres números, si todos los valores ingresados
// son menores a 10, imprimir en pantalla la leyenda
// "Todos los números son menores a diez".

#include <stdio.h>

int main()
{
    // Creamos tres variables enteras para guardar los números ingresados.
    int n1, n2, n3;

    // Pedimos el primer número y lo guardamos en n1.
    printf("Ingrese el primer número: ");
    scanf("%d", &n1);

    // Pedimos el segundo número y lo guardamos en n2.
    printf("Ingrese el segundo número: ");
    scanf("%d", &n2);

    // Pedimos el tercer número y lo guardamos en n3.
    printf("Ingrese el tercer número: ");
    scanf("%d", &n3);

    // && significa "Y".
    // Para entrar al if, TODAS las condiciones deben ser verdaderas:
    // n1 debe ser menor a 10
    // Y n2 debe ser menor a 10
    // Y n3 debe ser menor a 10.
    if (n1 < 10 && n2 < 10 && n3 < 10)
    {
        printf("Todos los números son menores a diez\n");
    }

    return 0;
}