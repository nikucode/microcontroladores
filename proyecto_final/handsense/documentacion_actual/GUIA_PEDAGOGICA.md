# Aprender HandSense de principio a fin — guía práctica y verificable

**Para quién:** Alex, Cote, docentes y personas que conocen algo de programación pero no han desarrollado un wearable BLE.  
**Método:** comprender → predecir → probar → observar → explicar. **No confundas un esquema con una simulación eléctrica ni una simulación con un prototipo real.**

## 1. ¿Qué problema investigamos?
Una persona puede flexionar el índice sin llegar a tocar el pulgar. Si contamos toda flexión como pinza, obtenemos un conteo mayor de lo que observamos como pinza completa. HandSense propone observar **dos señales distintas** y explicar el resultado. Compararemos el algoritmo por flexión con el combinado sobre las **mismas señales**. No afirmar mejora estadística hasta calcularla con intentos etiquetados externamente.

**Preguntas de repaso:** ¿por qué flexión sola no equivale a contacto? ¿qué efecto tiene un sensor desconectado? ¿cómo distinguimos movimiento incompleto de señal no interpretable?

## 2. De una fuerza o movimiento a un dato
1. Un sensor flexivo resistivo modifica su resistencia al doblarse. **No entrega grados directamente**.
2. El FSR reduce normalmente su resistencia cuando aumenta la presión. **No entrega newtons automáticamente**.
3. Cada sensor se incorpora en un **divisor de tensión** a 3,3 V para obtener una entrada eléctrica medible.
4. El ADC del XIAO convierte el voltaje en un número; resolución nominal no equivale a precisión física.
5. Con referencias instrumentales medimos y estimamos errores. Conservamos los voltajes y lecturas crudas antes de normalizar.

### Divisor de flexión (propuesto)
```text
3V3 ── [R fija 47 kΩ] ──┬── D1/GPIO3 ADC1
                         │
                  [sensor flexivo]
                         │
                        GND
```
Para un suministro ideal de 3,3 V, `Vflex = 3,3 × Rflex/(47.000 + Rflex)`. Por ejemplo, si hipotéticamente `Rflex = 47 kΩ`, entonces `Vflex = 1,65 V`. **Ejemplo calculado**, no resultado de nuestro sensor. Si Rflex sube, el voltaje del nodo sube.

### Divisor de contacto (propuesto)
```text
3V3 ── [FSR402] ──┬── D2/GPIO4 ADC1
                   │
                [10 kΩ]
                   │
                  GND
```
`Vfsr = 3,3 × 10.000/(Rfsr + 10.000)`. Si hipotéticamente el FSR tiene 10 kΩ, `Vfsr = 1,65 V`; al presionar y reducir la resistencia, el voltaje del nodo **aumenta**. **Ejemplo calculado**. Estas son aproximaciones de divisor ideal; el ADC tiene no linealidad y requiere calibración.

**Ejercicio:** con `Rflex=23,5 kΩ`, calcula `Vflex=3,3 × 23,5/(47+23,5) = 1,10 V`. Compara con multímetro real una vez montado y registra diferencias.

## 3. Qué placa y qué pin usar
Placa acordada: **Seeed XIAO ESP32-C3**. D1/A1 ↔ GPIO3 y D2/A2 ↔ GPIO4, ambas entradas ADC1. D4/GPIO6 LED verde; D5/GPIO7 LED ámbar; D6/GPIO21 **reservado** para driver motor y revisar el uso UART. El firmware de Wokwi en `firmware/logica_gesto/` utiliza GPIO34/35 **solo para ESP32 clásico** y no debe copiarse literalmente.

**Antes de encender:** revisar tensión 3V3, continuidad de rieles de protoboard, GND común, polaridad LED y ausencia de cortocircuito. **No conectar motor a GPIO ni improvisar fuente de motor**.

## 4. Comprender la máquina de estados
Archivo histórico: [gesture_logic.h](../firmware/logica_gesto/gesture_logic.h).
- **Umbral de activación y desactivación:** `ThresholdLatch` utiliza histéresis; evita alternancia cerca de un solo valor.
- **Contador flex-only:** `FlexOnlyCounter` cuenta el ciclo activo→inactivo de la señal flexiva.
- **Fusion:** `GestureDetector` recuerda si hubo flexión y contacto en el intento y, cuando ambos se apagan, puede aumentar `repetitions`.
- **Timeout:** a los 3000 ms de la versión publicada, clasifica el intento incompleto y espera reposo.
- **ESPERA_REPOSO:** evita volver a emitir eventos mientras las entradas continúan activas.

**Diferencia que debes saber defender:** esta versión actual **no rechaza necesariamente el contacto antes de flexión ni la activación simultánea**. Aunque un diagrama describa REPOSO→FLEXION→CONTACTO→LIBERACION, el código acumula `seenFlex_` y `seenContact_`; por ello, el orden es una **limitación** hasta definir e implementar la política final. No afirmar en el póster que se verifica una secuencia estricta si no se demostró.

## 5. Microexperimento: predecir resultados sin hardware
| Entradas | Resultado previsto en versión histórica | Qué prueba |
|---|---|---|
| Reposo → flexión → contacto → soltar contacto → soltar flexión | COMPLETA | Secuencia esperada |
| Reposo → flexión → reposo sin contacto | SIN_CONTACTO | Evita conteo por fusión |
| Reposo → contacto → reposo sin flexión | SIN_FLEXION | Distingue falta de flexión |
| Ambas activas sin liberarse durante timeout | SIN_LIBERACION | Bloqueo temporal |
| Contacto primero → flexión → reposo antes de timeout | **Puede dar COMPLETA** | Limitación de orden |
| Ambas señales simultáneas → reposo antes de timeout | **Puede dar COMPLETA** | Limitación de orden |

Una simulación Wokwi no demuestra comodidad, ángulo correcto ni precisión de FSR.

## 6. Cómo verificar en una computadora
```bash
cd proyecto_final/handsense/firmware/logica_gesto
g++ -std=c++17 -Wall -Wextra -pedantic test_logic.cpp -o /tmp/handsense_logic_test
/tmp/handsense_logic_test
```
Esperado, si compila y funciona: `5 pruebas de lógica HandSense aprobadas`. Se trata de cinco bloques de prueba con aserciones; no garantiza cobertura completa ni funcionamiento físico. Si vas a mejorar el orden de los gestos, **agrega primero pruebas de contacto primero y simultáneo, y luego corrige sin romper las otras cinco**.

La demostración web histórica: `app/`, probar `node --test data.test.js` desde su carpeta. **No confundir sus escenarios con mediciones.**

## 7. Aplicación Android, BLE y estados de comunicación
La interfaz Flutter local se diseñó con **Inicio, Ejercicio, Historial y Ajustes**, cinco escenarios de demostración y accesibilidad. Los registros Codex informan siete pruebas Flutter aprobadas y APK construido, pero los **fuentes móviles no están aún en GitHub main**. Sin `pubspec.yaml`, `lib/` y `android/` no es reproducible desde GitHub.

BLE GATT separa:
- **Descubrimiento** (el celular ve los anuncios).
- **Conexión** (se conecta a un dispositivo).
- **Notificación** (ESP32 transmite mediciones/eventos).
- **Escritura** (Flutter manda comando).
- **Confirmación** (ESP32 informa que aceptó el comando). **Enviar ≠ confirmar**.

El diagnóstico Codex descrito en sesiones usa `HS1,C,PING` y espera `HS1,A,PING,OK`. **Los UUID todavía deben extraerse del código local**; no copiar los de otro laboratorio con `PING`→`ACK,PING`.

## 8. Calibración y error: qué tenemos que medir
Para un registro válido: fecha, placa, tensión de alimentación, resistor fijo, valor ADC, voltaje leído por ADC o calibración, voltaje medido por multímetro, postura o carga de referencia, observaciones y foto del montaje.

**Error absoluto de voltaje:** `|V_ADC_estimado − V_multímetro|`.  
**Error porcentual respecto de referencia no nula:** `100 × |V_ADC_estimado−V_ref|/|V_ref|`. Cuando la referencia es 0 V, **no** usar error porcentual relativo.

Ángulos: solo declarar grados cuando existan posiciones y referencia angular controlada. FSR: en ausencia de dinamómetro o calibración validada, reportar **voltaje o porcentaje relativo de contacto**, no fuerza exacta. Los objetivos se desprenden de la rúbrica; no simular datos para llenar la tabla del tríptico.

## 9. Método de validación
Preparar ensayo de pinza completa, flexión sin contacto, contacto sin flexión, contacto sostenido, reintento tras reposo, reinicio, pérdida BLE y comando de la app. Para cada uno registrar etiqueta observada independientemente, esperado, observado, error y evidencia. Distinguir **pruebas de desarrollo** (ajustar umbrales) de **pruebas de evaluación** (no cambiar parámetros tras observar el resultado). Repeticiones del mismo equipo no equivalen a usuarios independientes.

## 10. Recorrido de aprendizaje recomendado
1. Explicar con palabras simples los dos sensores y sus limitaciones.
2. Calcular dos voltajes de los divisores y verificar la orientación de cada uno.
3. Predecir los seis escenarios del apartado 5, y demostrar cuáles fallan por diseño.
4. Leer `test_logic.cpp` y explicar sus cinco aserciones.
5. Dibujar el flujo ESP32→BLE→Flutter y explicar respuesta a `PING`.
6. Reproducir mediciones físicas, informar error y distinguir resultados medidos de simulados.
7. Defender **por qué HandSense es experimental**, no una herramienta terapéutica validada.
