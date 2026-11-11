# HandSense móvil — experiencia Android 0.2

Cuatro destinos: Inicio, Ejercicio, Historial y Ajustes. La versión anterior fue compilada e instalada por Alex; esta actualización requiere nueva compilación y verificación en el teléfono.

## Uso

1. Inicio explica el propósito y muestra dispositivo sin conectar.
2. «Explorar el ejercicio» abre instrucciones y una representación simbólica de la pinza.
3. «Explorar ejemplos simulados» despliega los cinco escenarios. Cada pulsación genera un resultado predeterminado, sin simular adquisición continua ni ejecutar el clasificador del ESP32.
4. «Por qué se contó» explica el último resultado. No evaluable se contabiliza aparte de incompleto.
5. «Finalizar y ver sesión» conserva una instantánea en Historial y vacía la sesión activa. Entrar a una sesión muestra todos sus intentos y explicaciones.
6. Ajustes permite ampliar texto sobre la escala de Android y aumentar contraste. Calibración informa que aún está pendiente.

Sesiones y ajustes viven **solo en memoria**; se pierden cuando el proceso termina. No hay BLE, datos reales, calibración ni almacenamiento persistente en esta versión.

## Arquitectura

- `data/attempt.dart`: conserva resultados y explicaciones; añade instantáneas inmutables de sesión.
- `AttemptSource`: flujo de eventos con origen explícito. Una fuente futura BLE implementará esta interfaz; no necesita simular.
- `DemoControls`: capacidad separada para generar ejemplos, implementada por `DemoRepository`.
- `ui/session_model.dart`: recibe eventos, conserva sesión activa y archivo temporal, calcula contadores; posee y libera la fuente y suscripción.
- `ui/screens.dart`: pantallas y componentes compartidos Panel, CounterSummary y AttemptExplanation.
- `main.dart`: navegación, tema y preferencias de presentación. Ancho máximo 760; navegación envuelve sus botones al aumentar texto o reducir ancho.

La fuente BLE requerirá después estado de conexión/calibración, protocolo y deduplicación de eventos. La abstracción actual prepara el flujo de intentos; no afirma resolver esos requisitos.

## Verificar desde la terminal de Alex

```bash
cd ~/Documents/Github/microcontroladores/proyecto_final/handsense/mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
"$HOME/Android/Sdk/platform-tools/adb" install -r build/app/outputs/flutter-apk/app-debug.apk
```

Estado de verificación de esta actualización:

- `flutter analyze --no-pub`: sin observaciones.
- `flutter test --no-pub`: no ejecutó las pruebas; apertura de socket 127.0.0.1 rechazada por Codex.
- `flutter build apk --debug --no-pub`: Gradle no pudo crear FileLockContentionHandler por no determinar una IP utilizable. No se generó un APK nuevo aquí.
- DTD/hot reload: intentados; no hay aplicación conectada.

Las pruebas cubren los cinco escenarios, categorías y conteos, archivo inmutable, sesión nueva, navegación, detalle, información de calibración y anchos 320/800 con texto al 200 %. Su resultado queda pendiente en la terminal sin restricciones.

## Recorrido manual en teléfono

Probar Inicio → Ejercicio → abrir ejemplos → los cinco escenarios → finalizar → Historial → abrir detalle → volver → Ajustes. Verificar totales 1 completo, 3 incompletos y 1 no evaluable. Regresar a Ejercicio y comprobar contadores cero con la sesión anterior intacta. Cambiar contraste y tamaño, repetir en horizontal y con texto de Android ampliado. Con TalkBack revisar nombres, foco, resultado anunciado y acceso a detalles. No se declara conformidad de accesibilidad sin esta revisión.
