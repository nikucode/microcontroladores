# Reproducir lo publicado y diagnosticar lo que falta

## Preparación
Clonar **solo una vez**:
```bash
git clone https://github.com/nikucode/microcontroladores.git
cd microcontroladores/proyecto_final/handsense
```
No hay configuración compartida del ESP32/Flutter completamente publicable todavía; descargar el repositorio NO instala automáticamente un APK ni habilita BLE.

## A. Firmware de lógica (C++ sin placa)
```bash
cd firmware/logica_gesto
g++ -std=c++17 -Wall -Wextra -pedantic test_logic.cpp -o /tmp/handsense_logic_test
/tmp/handsense_logic_test
```
Si el ejecutable se construye y finaliza correctamente, imprime `5 pruebas de lógica HandSense aprobadas`. Estas pruebas no incluyen explícitamente orden inverso, simultaneidad ni pérdida física de sensor.

## B. Simulación de adquisición y gestos
- En Wokwi crear proyecto ESP32 DevKit clásico, importar `firmware/adquisicion/sketch.ino` + `diagram.json`, ejecutar y observar `Serial`.
- Crear segundo proyecto con `firmware/logica_gesto/sketch.ino`, `gesture_logic.h` y su `diagram.json`.
- Iniciar ambos potenciómetros bajos. Para completa: subir flex, subir contacto, bajar contacto, bajar flex. Para incompletos: solo flex y solo contacto.
- **GPIO34/35 y 18/19 son del modelo simulado antiguo**, no los pines de XIAO ESP32-C3 definitivo.
- Los umbrales 2457/1433 y timeout 3000 ms son de esa versión del sketch. La simulación manual no sustituye sensores.

## C. App web histórica
```bash
cd app
node --test data.test.js
python3 -m http.server 8000
```
Luego abrir `http://localhost:8000` **desde el computador que sirve esos archivos**. Es un prototipo web; **no es la app Android Flutter**. Si el puerto ya está ocupado, detener el servidor o elegir otro. Los datos del modo demo son ficticios.

## D. Flutter Android actual — pendiente de publicar desde el computador
Rutas reportadas:
```text
proyecto_final/handsense/mobile/
  lib/
  test/
  pubspec.yaml
  android/
```
La fuente se encuentra fuera de `main`. Una vez versionada, revisar compatibilidad con Flutter 3.47.7, `flutter_reactive_ble 5.5.0`, `permission_handler 12.0.3` y ajuste Gradle a compileSdk 36 reportados en sesión Codex. Los registros muestran `flutter analyze`, 7 pruebas superadas y `flutter build apk --debug` exitoso, pero **esto no equivale a verificación reproducida desde GitHub**.

## E. BLE — pendiente de versionar
Firmware diagnóstico local reportado: `firmware/ble_diagnostico/sketch.ino`. La aplicación debe suscribirse a GATT y enviar comando `HS1,C,PING`; ESP32 deberá notificar `HS1,A,PING,OK`. **Comparar los UUID del código real**. Probar con nRF Connect antes de Flutter. No usar el contrato HTTP histórico `app/PROTOCOLO.md` como protocolo BLE.

## F. Montaje de mesa XIAO
- Leer [conexiones](MONTAJE_Y_CONEXIONES_XIAO.md) y [inventario](INVENTARIO_Y_COMPRA.md).
- Primer ensayo sin motor: dos divisores a 3,3 V y LED de 330 Ω; medir voltajes y cortos **antes** de encender.
- No hay `.fzz` definitivo ni `SimulIDE` validado que pueda abrirse desde el repositorio.
- Motor y MOSFET requieren modelos reales documentados. Si no están, detener etapa de motor.
- Documentar placa, esquema, valores de resistencias, fuente, condiciones y logs.

## G. Fallos frecuentes (y diagnóstico)
| Síntoma | Comprobar primero |
|---|---|
| El XIAO no aparece en Bluetooth | Firmware BLE real cargado, antena, permisos, alimentación, anuncios |
| nRF Connect detecta dispositivo pero Flutter no | UUID y formato del mensaje, permiso Android, filtro de anuncios |
| Se envía PING sin respuesta | Característica escribible, suscripción de notificaciones, recepción UART, formato de comando |
| Flex y FSR están invertidos | Orientación de divisores, referencia GND, rango ADC; no ajustar algoritmo a ciegas |
| LED no prende | Polaridad, resistencia, pin GPIO, código |
| ESP32 se reinicia al activar motor | Fuente, corriente de arranque, masa común, diodo, filtrado y ruido |
| Ensayo dice «COMPLETA» sin gesto válido | Revisar máquina de estados y pruebas de contacto primero/simultáneo |
| Compilación Flutter falla por SDK | Verificar Gradle y versión plugin; no actualizar todo a ciegas |
| Cambian los valores de ADC al reconectar | Repetir calibración, comprobar alimentación, posición y presión de sensores |

## H. Criterio de reproducción completa
Un tercero debe poder obtener: código, versión de dependencias, esquema/pinout, BOM verificada, instrucciones de montaje, comandos de prueba, tramas BLE exactas, resultados y límites. **Hoy no se cumple integralmente**; los puntos faltantes están en [evidencias](EVIDENCIAS_Y_PENDIENTES.md).
