#include <stdio.h>

int main()
{
    int dia, mes;

    printf("Ingrese el dia: ");
    scanf("%d", &dia);

    printf("Ingrese el mes: ");
    scanf("%d", &mes);

    if (dia == 25 && mes == 12)
    {
        printf("La fecha corresponde a Navidad\n");
    }
    else
    {
        printf("La fecha no corresponde a Navidad\n");
    }

    return 0;
}