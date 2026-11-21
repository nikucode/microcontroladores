# Estado técnico y contrato de integración — 20-11-2026

## Confirmaciones respaldadas por registros de Codex / terminal
- Flutter Android local: navegación Inicio/Ejercicio/Historial/Ajustes y modo demostración. **7 pruebas Flutter aprobadas**, `flutter analyze` sin problemas y **APK debug compilado** luego de resolver dependencias Android.
- Dependencias de compilación registradas: `flutter_reactive_ble 5.5.0`, `permission_handler 12.0.3`; módulos transitivos reactive_ble 5.5.0 fijados y ajuste compileSdk 36 en Gradle.
- Pruebas de lógica C++: **5 aprobadas** en sesión Codex.
- Codex creó localmente `mobile/lib/data/ble_attempt_source.dart`, `handsense_protocol.dart` y `firmware/ble_diagnostico/sketch.ino`; los logs no sustituyen al código fuente.
- Wokwi: secuencia de pinza completa `fusion=1 flex_solo=1 inc=0` y flexión sin contacto `fusion=0 flex_solo=1 inc=1`, observadas en simulación.

## Pendiente de verificar
- **Instalación y prueba del APK BLE actualizado en teléfono** (la primera versión de Flutter sí se instaló).
- BLE físico ESP32 ↔ nRF Connect ↔ Flutter; aún sin registro real de `ACK`.
- ADC, sensores, motor y calibración física; persistencia al reiniciar.
- Historial persistente; actualmente se describió historial en memoria.
- Fritzing .fzz y simulación eléctrica de montaje real.

## Fuente principal: protocolo BLE preparado por Codex
**Diagnóstico BLE**:
- Nombre anunciado: `HandSense-BLE-Lab` (solo si la versión local coincide).
- Control por característica GATT escribible: enviar **texto UTF-8** `HS1,C,PING`.
- Respuesta de ESP32 esperada en notificaciones: `HS1,A,PING,OK`.
- Tramas de eventos con versión y secuencia según `mobile/lib/data/handsense_protocol.dart`.
- **UUID exactos:** leer de `app/PROTOCOLO.md` **local actualizado** y `firmware/ble_diagnostico/sketch.ino`; **no se pudieron inspeccionar aquí**, así que no inventarlos.

**ADVERTENCIA:** un laboratorio BLE diseñado anteriormente fuera de Codex usaba `PING` → `ACK,PING` y `RATE=500`. **No es el protocolo vigente del Codex**. No mezclarlos. El archivo `app/PROTOCOLO.md` publicado a fecha de corte aún describe Wi-Fi/HTTP; es documentación histórica, NO contrato BLE actual.

## Acciones obligatorias para sincronizar el repositorio
1. En el computador con Codex: `git status --short`, `git branch -vv`, `git fetch origin`, `git log --oneline --all -12`.
2. Inspeccionar `mobile/`, `firmware/ble_diagnostico/`, `app/PROTOCOLO.md` y cambios en Gradle. Verificar pruebas y que no haya secretos ni artefactos de compilación.
3. **No publicar a ciegas** `build/`, `.dart_tool/`, `android/local.properties`, `.gradle/`, APK debug ni archivos de otros proyectos.
4. Subir código local en commits acotados; integrar o rebasar sobre lo publicado con revisión de diferencias. No usar `git push --force`.
5. Actualizar aquí UUID reales, modelo/driver de motor y evidencia de conexión una vez comprobados.

## Política de evidencia
- **Probado:** acompañar con comando, captura, video, CSV o log.
- **Preparado:** existe código, pero no implica ejecución física.
- **Calculado:** resultado teórico, no medición.
- **Pendiente:** faltan pruebas.
