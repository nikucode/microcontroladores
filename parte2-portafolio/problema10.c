// Se ingresan tres valores enteros por teclado. Si los tres valores son 
// iguales, calcular e imprimir el resultado de: (primero + segundo) * tercero.

#include <stdio.h>

int main(){
    int n1, n2, n3, resultado;
    printf("Ingrese el primer valor: ");
    scanf("%d", &n1);
    printf("Ingrese el segundo valor: ");
    scanf("%d", &n2);
    printf("Ingrese el tercer valor: ");
    scanf("%d", &n3);

    if(n1 == n2 && n2 == n3){
        resultado = (n1 + n2) * n3;
        printf("El resultado es: %d\n", resultado);
    } else {
        printf("Los valores ingresados no son iguales\n");
    }
    return 0;
}