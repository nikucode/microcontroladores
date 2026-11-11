# HandSense móvil — primera demostración Android

App Flutter con ejemplos explícitamente simulados. Permite explorar resultados y explicaciones de intentos; conserva el historial solo en memoria. No integra todavía BLE, SQLite ni calibración física. No ejecuta el clasificador del ESP32: los resultados son ejemplos predeterminados.

## Ejecutar desde la terminal del usuario

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

APK esperado: `build/app/outputs/flutter-apk/app-debug.apk`. Con teléfono autorizado por USB: `flutter devices` y `flutter run -d IDENTIFICADOR`. La depuración y el APK siguen pendientes de verificar en un teléfono.

## Organización

`lib/data/attempt.dart`: modelos inmutables y repositorio de demostración.
`lib/ui/session_model.dart`: estado y conteos ilustrativos.
`lib/main.dart`: vista adaptable con etiquetas y explicaciones desplegables.

La distinción entre no evaluable e incompleto continúa las decisiones documentadas en `../app/DECISIONES.md`. La separación del origen de datos permite incorporar un repositorio BLE más adelante, con identificadores de eventos y recuperación de desconexión.

Verificación en Codex: dependencias resueltas desde caché y análisis sin problemas. Pruebas Flutter bloqueadas al abrir socket local; Gradle bloqueado al descargar su distribución. No se generó APK ni se pudo hacer hot reload porque no hay aplicación conectada a DTD.
