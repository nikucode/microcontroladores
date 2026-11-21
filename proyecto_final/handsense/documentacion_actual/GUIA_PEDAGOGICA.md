# Cómo funciona HandSense, de sensor a aplicación

**Método:** comprender → predecir → probar → observar → explicar. Un esquema no es una simulación y una simulación no es una prueba física.

## Problema que investigamos

Flexionar el índice no demuestra que haya contacto con el pulgar. HandSense compara un contador por flexión con otro que exige ambas señales y explica el resultado. La hipótesis de mejora solo puede evaluarse sobre las mismas señales, usando etiquetas observadas independientemente.

## 1. Sensores y divisores

El flexivo y el FSR cambian su resistencia. Un divisor transforma ese cambio en tensión. El ADC solo observa la tensión del nodo; no conoce grados ni newtons. Antes de conectar, medir resistencia en reposo/activo y calcular el rango previsto. Resultado esperado: tensión variable, siempre dentro del rango medible del ADC. Si queda fija, revisar continuidad, orientación del divisor y masa común.

Divisores preliminares:

```text
3V3 ─ 47 kΩ ─ nodo FLEX/D1 ─ sensor flexivo ─ GND
3V3 ─ FSR402 ─ nodo FSR/D2 ─ 10 kΩ ─ GND
```

`Vflex = 3,3 × Rflex/(47.000 + Rflex)` y `Vfsr = 3,3 × 10.000/(Rfsr + 10.000)`. Si cualquiera de los sensores tuviera hipotéticamente la misma resistencia que su resistor fijo, el nodo sería 1,65 V. Es un cálculo didáctico, no una medición del prototipo.

## 2. ADC del XIAO ESP32-C3

D1/GPIO3 y D2/GPIO4 pertenecen a ADC1. Configurar 12 bits y atenuación coherente; registrar tanto valor crudo como milivoltios calibrados. Comparar cada lectura con multímetro. El valor nominal de 4095 no demuestra 3,3 V: la referencia varía y el rango útil depende de la atenuación. Si se satura, corregir el divisor antes de ajustar umbrales.

## 3. Filtrado, histéresis y estados

El promedio móvil reduce ruido. Dos umbrales distintos evitan encendidos/apagados rápidos cerca del límite. El detector acepta únicamente `REPOSO → FLEXION → CONTACTO → LIBERACION → REPOSO`. Contacto primero, simultaneidad o liberación invertida son incompletos; un timeout obliga a volver a reposo antes del siguiente intento.

| Secuencia | Resultado esperado actual |
|---|---|
| flexión → contacto → soltar contacto → soltar flexión | `COMPLETA` |
| flexión → reposo | `SIN_CONTACTO` |
| contacto → reposo | `SIN_FLEXION` |
| contacto antes de flexión o ambas simultáneas | `SIN_FLEXION`, nunca completa |
| soltar flexión antes del contacto | `SIN_LIBERACION` |
| mantener intento hasta timeout | incompleto y `ESPERA_REPOSO` |

## 4. Actuadores

Los LED llevan resistencia serie. El motor no se conecta directamente al GPIO: requiere driver compatible, protección y fuente dimensionada según el modelo real. Probar primero LED, luego driver sin motor y finalmente motor, vigilando reinicios y corriente.

## 5. BLE

El ESP32 anuncia un servicio GATT. La app se suscribe a `Eventos` y escribe en `Control`. `HS1,C,PING` solo se considera exitoso al recibir `HS1,A,PING,OK`. Las tramas `E` transmiten resultados, no lecturas continuas; la telemetría ADC sigue pendiente de diseñar e integrar.

## 6. Flutter

El modo demostración genera ejemplos claramente rotulados. La fuente BLE implementa la misma interfaz, pero solo almacena eventos que superan el parser y elimina secuencias repetidas. Historial y ajustes aún viven en memoria. Compilar la app no demuestra que el enlace físico funcione.

## 7. Evidencia

Etiquetar siempre el nivel: **calculado**, **simulado**, **prueba automatizada**, **implementado sin validar** o **medido físicamente**. Un ensayo físico debe incluir versión de firmware, montaje, referencia, unidades, condiciones, archivo y limitaciones.

El error absoluto de voltaje es `|V_ADC − V_multímetro|`. El error porcentual es `100 × |V_ADC−V_ref|/|V_ref|` solo cuando la referencia no es cero. Para grados se necesita referencia angular; para newtons, referencia de fuerza. Sin ellas se informa lectura cruda, voltaje o porcentaje relativo.

## Recorrido de aprendizaje

1. Explicar qué cambia físicamente en cada sensor.
2. Calcular y luego medir ambos divisores.
3. Predecir las seis secuencias de la tabla.
4. Leer las nueve pruebas y relacionarlas con la máquina de estados.
5. Dibujar ESP32 → BLE → Flutter y explicar por qué escribir no equivale a recibir ACK.
6. Repetir ensayos, informar errores y defender por qué el prototipo sigue siendo experimental.
