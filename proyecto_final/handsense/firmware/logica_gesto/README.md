# Segunda simulación: lógica del gesto

Esta etapa convierte las dos entradas independientes en una secuencia observable:

`REPOSO → FLEXION/CONTACTO → CONTACTO → LIBERACION → COMPLETA`

Una repetición se cuenta únicamente cuando hubo flexión y contacto y luego ambas entradas regresaron a reposo. El LED verde se enciende durante 400 ms al completar la secuencia. El LED naranja indica un intento incompleto: falta contacto, falta flexión o no hubo liberación antes de tres segundos.

El monitor serie presenta dos contadores sobre las mismas entradas: `fusion` exige la secuencia completa y `flex_solo` cuenta cada ciclo de flexión. En el ensayo «solo flexión», `flex_solo` aumenta y `fusion` no; este es el caso básico para comparar los algoritmos A y B planteados en la investigación.

El ESP32 sigue leyendo y procesando las entradas cada 20 ms, pero el monitor serie ahora muestra una línea solo cuando cambia el estado, ocurre un evento, cambia un contador o pasa un segundo. Así las transiciones se ven al momento y las lecturas periódicas quedan a una línea por segundo. Las columnas aparecen como `F` (flexión), `C` (contacto), `estado`, `evento`, `fusion`, `flex_solo` e `inc` (incompletas).

## Probar en Wokwi

1. Crear otro proyecto ESP32 o reemplazar los archivos del proyecto de adquisición por `sketch.ino`, `gesture_logic.h` y `diagram.json` de esta carpeta.
2. Iniciar la simulación con ambos potenciómetros al mínimo.
3. Para una repetición completa: subir flexión, subir contacto, bajar contacto y bajar flexión. Debe aparecer `COMPLETA`, aumentar el contador y encenderse el LED verde.
4. Subir y bajar solamente flexión. Debe aparecer `SIN_CONTACTO` y encenderse el LED naranja.
5. Subir y bajar solamente contacto. Debe aparecer `SIN_FLEXION`.
6. Subir ambos y mantenerlos más de tres segundos. Debe aparecer una sola vez `SIN_LIBERACION`; hay que bajar ambos antes de comenzar otro intento.

Los límites de entrada son provisionales para potenciómetros: activación sobre 60 % del ADC y desactivación bajo 35 %. La separación crea histéresis y evita que pequeñas oscilaciones cerca de un único umbral cambien continuamente el estado. Los límites físicos deberán surgir de la calibración y de registros reales.

El sketch aplica una media móvil de cinco muestras. Durante sus primeros 100 ms los valores parten desde cero mientras se llena el búfer; esta fase no debe usarse para iniciar un ensayo.

## Pruebas del algoritmo

La lógica se encuentra en un archivo C++ independiente del ESP32 para comprobar sus casos principales en el computador:

```bash
g++ -std=c++17 -Wall -Wextra -pedantic test_logic.cpp -o /tmp/handsense_logic_test
/tmp/handsense_logic_test
```

Estas pruebas verifican: repetición completa, flexión sin contacto, contacto sin flexión, tiempo máximo sin liberación e histéresis. La prueba en Wokwi todavía es necesaria para validar la integración de ADC, filtro, LED y monitor serie.
