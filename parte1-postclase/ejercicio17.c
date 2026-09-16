// De un operario se conoce su sueldo y los años de antigüedad. 
// Se requiere desarrollar un programa que lea los datos de entrada e informe:
// a) Si el sueldo es inferior a 500 y su antigüedad es igual o superior a 10 años, otorgarle un aumento del 20 %, mostrar el sueldo a pagar.
// b) Si el sueldo es inferior a 500 pero su antigüedad es menor a 10 años, otorgarle un aumento de 5 %.
// c) Si el sueldo es mayor o igual a 500 mostrar el sueldo en pantalla sin cambios.

#include <stdio.h>

int main()
{
    // Guardamos el sueldo y la antiguedad del operario
    float sueldo;
    int antiguedad;

    // Pedimos al usuario que ingrese el sueldo
    printf("Ingrese el sueldo del operario: ");
    scanf("%f", &sueldo);

    // Pedimos al usuario que ingrese la antiguedad
    printf("Ingrese la antiguedad del operario (en años): ");
    scanf("%d", &antiguedad);

    // Si el sueldo es menor a 500 y la antiguedad es mayor o igual a 10, aumento del 20%
    if (sueldo < 500 && antiguedad >= 10)
    {
        sueldo = sueldo * 1.20; // Aumento del 20%
        printf("Sueldo a pagar con aumento del 20%%: %.2f\n", sueldo);
    }
    // Si el sueldo es menor a 500 y la antiguedad es menor a 10, aumento del %70
    else if (sueldo < 500 && antiguedad < 10)
    {
        sueldo = sueldo * 1.05; // Aumento del 5%
        printf("Sueldo a pagar con aumento del 5%%: %.2f\n", sueldo);
    }
    // Si el sueldo es mayor o igual a 500, no hay cambios
    else
    {
        printf("Sueldo a pagar sin cambios: %.2f\n", sueldo);
    }

    return 0;
}