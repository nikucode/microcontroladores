// Confeccionar un programa que solicite el pago por hora de un
// empleado y la cantidad de horas trabajadas dentro de una estructura repetitiva
// en la función main. Elaborar una función que reciba como parámetro el valor
// de la hora y la cantidad de horas trabajadas y nos muestre el total a pagar.

#include <stdio.h>

void calcularPago(float pagoPorHora, int horasTrabajadas)
{
    float totalAPagar = pagoPorHora * horasTrabajadas;
    printf("El total a pagar es: %.2f\n", totalAPagar);
}

int main()
{
    float pagoPorHora;
    int horasTrabajadas;

    printf("Ingrese el pago por hora: ");
    scanf("%f", &pagoPorHora);
    printf("Ingrese la cantidad de horas trabajadas: ");
    scanf("%d", &horasTrabajadas);

    calcularPago(pagoPorHora, horasTrabajadas);

    return 0;
}