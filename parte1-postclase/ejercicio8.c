// Dado que el usuario ingresa la edad de una persona, determinar e
// informar si dicha persona es mayor de edad (18 años o más)

#include <stdio.h>

int main() 
{
    int edad;

    printf("Ingrese la edad de la persona: ");
    scanf("%d", &edad);

    if (edad >= 18)
    {
        printf("La persona es mayor de edad.\n");
    }
    else
    {
        printf("La persona es menor de edad.\n");
    }

    return 0;
}