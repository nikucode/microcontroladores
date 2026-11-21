# Reproducibilidad y diagnóstico

## Lógica C++

```bash
cd proyecto_final/handsense/firmware/logica_gesto
g++ -std=c++17 -Wall -Wextra -pedantic test_logic.cpp -o /tmp/handsense_logic_test
/tmp/handsense_logic_test
```

Esperado: `9 pruebas de lógica HandSense aprobadas`. Si falla, no cargar el clasificador hasta revisar el caso indicado.

## Simulaciones históricas Wokwi

- `firmware/adquisicion/`: importar `sketch.ino` y `diagram.json` en un ESP32 DevKit clásico.
- `firmware/logica_gesto/`: importar además `gesture_logic.h`.
- Para completa: flexión arriba → contacto arriba → contacto abajo → flexión abajo.
- GPIO34/35, LED 18/19, umbrales 2457/1433 y timeout 3000 ms pertenecen a la simulación histórica; no copiarlos al XIAO.

## App web histórica

```bash
cd proyecto_final/handsense/app
node --test data.test.js
```

Esperado: 5 pruebas. Son datos simulados y no verifican BLE.

## Flutter Android

```bash
cd proyecto_final/handsense/mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Esperado según la terminal de Alex: análisis limpio, 7 pruebas y `build/app/outputs/flutter-apk/app-debug.apk`. Si Gradle reclama SDK 37, comprobar que el `pubspec.lock`, overrides 5.5.0 y ajuste del subproyecto BLE coincidan con Git antes de actualizar dependencias.

## BLE sin sensores

1. Cargar `firmware/ble_diagnostico/sketch.ino` en la placa confirmada.
2. Abrir monitor serie a 115200 y buscar `Anunciando HandSense-BLE-Lab`.
3. En nRF Connect, conectar al servicio UUID documentado, habilitar notificaciones en Eventos y escribir `HS1,C,PING` en Control.
4. Esperado: notificación `HS1,A,PING,OK` y registro RX/TX serie.
5. Repetir desde Flutter; desconectar/reconectar y registrar ambos resultados.

Si el dispositivo no aparece: revisar placa seleccionada, firmware cargado, alimentación, antena y permisos. Si aparece pero no responde: comparar UUID, característica, suscripción, escritura con respuesta y texto exacto.

## Montaje físico progresivo

1. Verificar modelo/pinout y cortocircuito 3V3–GND con fuente apagada.
2. Encender XIAO solo por USB y comprobar BLE.
3. Añadir un divisor, medir nodo con multímetro y comparar ADC; luego el segundo.
4. Añadir LED individualmente.
5. Integrar driver/motor únicamente con modelo, tensión y corriente confirmados.

Resultado de cierre: registros de voltaje/ADC, eventos, reconexión, comando, actuadores y clasificación. Sin esos archivos, el montaje sigue pendiente aunque compile.

## Fallos frecuentes

| Síntoma | Comprobar primero |
|---|---|
| XIAO no aparece por BLE | firmware cargado, placa, alimentación, antena y anuncios |
| nRF Connect conecta pero Flutter no | UUID, permisos Android y filtro de servicio |
| `PING` no recibe ACK | suscripción a Eventos, escritura en Control y texto exacto |
| lecturas saturadas | atenuación, voltaje con multímetro y orientación del divisor |
| flex/FSR parecen invertidos | nodos, masa común y polaridad observada antes de cambiar código |
| motor reinicia la placa | corriente de arranque, fuente, driver, diodo, masa y desacoplamiento |
| evento completo con orden incorrecto | versión del detector y ejecución de las nueve pruebas |
| Gradle reclama SDK | `pubspec.lock`, overrides BLE 5.5.0 y configuración Gradle versionada |

## Reproducción completa

Un tercero necesita código, versiones, pinout, BOM real, montaje, comandos, protocolo, resultados y límites. El repositorio todavía no alcanza este nivel porque faltan firmware XIAO integrado, inventario y evidencia física.
