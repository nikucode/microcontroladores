// Se ingresa por teclado un número entero positivo de uno o dos dígitos
// (Por ejemplo, 99 tiene dos dígitos y 5 tiene un dígito) mostrar un mensaje
// indicando si el número tiene uno o dos dígitos.
// (Tener en cuenta qué condición debe cumplirse para que un número tenga dos dígitos)

#include <stdio.h>

int main()
{
    // Creamos una variable para guardar el numero ingresado
    int numero;

    // Pedimos al usuario que ingrese un numero entero positivo
    printf("Ingrese un numero entero positivo de uno o dos digitos: ");
    scanf("%d", &numero);

    // Verificamos si el numero tiene uno o dos digitos
    if (numero >= 0 && numero <= 9)
    {
        printf("El numero tiene un digito.\n");
    }
    else if (numero >= 10 && numero <= 99)
    {
        printf("El numero tiene dos digitos.\n");
    }
    else
    {
        printf("El numero no es de uno o dos digitos.\n");
    }

    return 0;
}