// Al introducir la edad de una persona, saber si es mayor de edad o no

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
