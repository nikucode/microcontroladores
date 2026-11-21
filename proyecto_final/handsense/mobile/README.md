# HandSense móvil — experiencia Android y base BLE 0.3

Cuatro destinos: Inicio, Ejercicio, Historial y Ajustes. La versión anterior fue compilada e instalada por Alex; esta actualización requiere nueva compilación y verificación en el teléfono.

## Uso

1. Inicio explica el propósito y permite conservar la demostración o buscar un dispositivo que anuncie el servicio GATT de HandSense.
2. «Explorar el ejercicio» abre instrucciones y una representación simbólica de la pinza.
3. «Explorar ejemplos simulados» despliega los cinco escenarios. Cada pulsación genera un resultado predeterminado, sin simular adquisición continua ni ejecutar el clasificador del ESP32.
4. «Por qué se contó» explica el último resultado. No evaluable se contabiliza aparte de incompleto.
5. «Finalizar y ver sesión» conserva una instantánea en Historial y vacía la sesión activa. Entrar a una sesión muestra todos sus intentos y explicaciones.
6. Ajustes permite ampliar texto sobre la escala de Android y aumentar contraste. Calibración informa que aún está pendiente.

Sesiones y ajustes viven **solo en memoria**; se pierden cuando el proceso termina. La fuente BLE está implementada, pero no equivale a una conexión comprobada: todavía falta compilar esta actualización y probarla con el ESP32 físico. No hay calibración ni almacenamiento persistente.

## Arquitectura

- `data/attempt.dart`: conserva resultados y explicaciones; añade instantáneas inmutables de sesión.
- `AttemptSource`: flujo de eventos con origen explícito, compartido por la demostración y el dispositivo.
- `data/ble_attempt_source.dart`: permisos, búsqueda, conexión GATT, notificaciones, deduplicación y `PING` con ACK.
- `data/handsense_protocol.dart`: UUID y mensajes compactos versionados que el firmware debe implementar.
- `DemoControls`: capacidad separada para generar ejemplos, implementada por `DemoRepository`.
- `ui/session_model.dart`: recibe eventos, conserva sesión activa y archivo temporal, calcula contadores; posee y libera la fuente y suscripción.
- `ui/screens.dart`: pantallas y componentes compartidos Panel, CounterSummary y AttemptExplanation.
- `main.dart`: navegación, tema y preferencias de presentación. Ancho máximo 760; navegación envuelve sus botones al aumentar texto o reducir ancho.

La app no inventa conexión ni mediciones: solo marca datos como físicos después de conectar y recibir notificaciones válidas. Dirección, placa, GPIO y funcionamiento del firmware físico siguen pendientes.

## Verificar desde la terminal de Alex

```bash
cd ~/Documents/Github/microcontroladores/proyecto_final/handsense/mobile
flutter pub get &&
flutter analyze &&
flutter test &&
flutter build apk --debug &&
"$HOME/Android/Sdk/platform-tools/adb" install -r build/app/outputs/flutter-apk/app-debug.apk
```

Estado de verificación de la experiencia 0.2:

- `flutter analyze --no-pub`: sin observaciones.
- Alex ejecutó `flutter test --no-pub` el 18 de noviembre: **4 pruebas aprobadas**.
- `flutter build apk --debug --no-pub`: Gradle no pudo crear FileLockContentionHandler por no determinar una IP utilizable. No se generó un APK nuevo aquí.
- DTD/hot reload: intentados; no hay aplicación conectada.

Las cuatro pruebas cubren los cinco escenarios, categorías y conteos, archivo inmutable, sesión nueva, navegación, detalle, información de calibración y anchos 320/800 con texto al 200 %.

Estado de la integración BLE 0.3:

- Las 5 pruebas C++ históricas del detector aprobaron nuevamente.
- `dart analyze` aprobó modelos, parser y pruebas del protocolo.
- Alex descargó inicialmente las versiones más recientes y las 7 pruebas aprobaron, pero Android SDK 37 quedó instalado como `android-37.0` y Gradle no pudo resolver el objetivo `android-37`. Se fijaron `flutter_reactive_ble 5.5.0` y `permission_handler 12.0.3`, compatibles con el SDK 35/36 existente; falta repetir la compilación.
- Por lo anterior, análisis completo, suite Flutter, APK y prueba BLE quedan pendientes en la terminal de Alex.

Contrato mínimo del ESP32: anunciar el servicio y características definidos en `lib/data/handsense_protocol.dart`, notificar `HS1,E,<secuencia>,<código>` y responder `HS1,A,PING,OK` al recibir `HS1,C,PING`.

## Recorrido manual en teléfono

Probar Inicio → Ejercicio → abrir ejemplos → los cinco escenarios → finalizar → Historial → abrir detalle → volver → Ajustes. Verificar totales 1 completo, 3 incompletos y 1 no evaluable. Regresar a Ejercicio y comprobar contadores cero con la sesión anterior intacta. Cambiar contraste y tamaño, repetir en horizontal y con texto de Android ampliado. Con TalkBack revisar nombres, foco, resultado anunciado y acceso a detalles. No se declara conformidad de accesibilidad sin esta revisión.

## Corrección de pruebas — 11 de noviembre de 2026

La ejecución compartida por Alex confirmó análisis sin observaciones y dos pruebas
aprobadas, pero fallaron navegación y pantalla pequeña con `Bad state: No element`.
La cadena se detuvo antes de compilar o instalar el APK.

El ayudante de pruebas usaba `ensureVisible` sobre elementos todavía no construidos
por `ListView`. Ahora desplaza la lista con `scrollUntilVisible` si el elemento no
existe todavía y luego lo pulsa. También vuelve hacia los contadores antes de
comprobarlos. Se conservan todas las aserciones y los tamaños de prueba; no se
modificó el código de la aplicación para ocultar el fallo.

Después de la corrección, `flutter analyze --no-pub` pasó. El intento de
`flutter test --no-pub` en Codex sigue bloqueado al abrir el socket local antes de
cargar las pruebas. Por tanto, falta confirmar esta corrección desde la terminal
de Alex; no se declara que la suite ya pase.
