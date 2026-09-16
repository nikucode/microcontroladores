#include <stdio.h>

int main()
{
    int n, f;
    int entre_100_300 = 0;
    int mas_300 = 0;
    float sueldo;
    float total = 0;

    printf("Ingrese la cantidad de empleados: ");
    scanf("%d", &n);

    for (f = 1; f <= n; f++)
    {
        printf("Ingrese el sueldo del empleado %d: ", f);
        scanf("%f", &sueldo);

        total = total + sueldo;

        if (sueldo >= 100 && sueldo <= 300)
        {
            entre_100_300 = entre_100_300 + 1;
        }
        else if (sueldo > 300)
        {
            mas_300 = mas_300 + 1;
        }
    }

    printf("Empleados entre $100 y $300: %d\n", entre_100_300);
    printf("Empleados con mas de $300: %d\n", mas_300);
    printf("Total gastado en sueldos: %.2f\n", total);

    return 0;
}