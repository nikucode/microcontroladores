# Estado técnico y contrato de integración — actualizado 24-11-2026

## Confirmaciones respaldadas por registros de Codex / terminal
- Flutter Android local: navegación Inicio/Ejercicio/Historial/Ajustes y modo demostración. **7 pruebas Flutter aprobadas**, `flutter analyze` sin problemas y **APK debug compilado** luego de resolver dependencias Android.
- Dependencias de compilación registradas: `flutter_reactive_ble 5.5.0`, `permission_handler 12.0.3`; módulos transitivos reactive_ble 5.5.0 fijados y ajuste compileSdk 36 en Gradle.
- Pruebas de lógica C++: **9 aprobadas** el 21-11; incluyen orden inverso, simultaneidad, liberación invertida y recuperación.
- Candidato físico XIAO: **14 grupos de pruebas aprobados** con regresiones,
  calibración, recuperación y desbordamiento temporal.
- `mobile/` y el diagnóstico BLE están versionados en `main`; su archivo
  principal local se renombró a `firmware/ble_diagnostico/ble_diagnostico.ino`
  para cumplir la convención de compilación de Arduino. Los logs no sustituyen
  una prueba física.
- Wokwi: secuencia de pinza completa `fusion=1 flex_solo=1 inc=0` y flexión sin contacto `fusion=0 flex_solo=1 inc=1`, observadas en simulación.

## Pendiente de verificar
- **Instalación y prueba del APK BLE actualizado en teléfono** (el APK actualizado compiló; ADB no encontró un teléfono conectado en el intento registrado).
- BLE físico ESP32 ↔ nRF Connect ↔ Flutter; aún sin registro real de `ACK`.
- ADC, sensores, motor y calibración física; persistencia al reiniciar.
- Historial persistente; actualmente se describió historial en memoria.
- Fritzing .fzz y simulación eléctrica de montaje real.

## Candidato integrado del 24-11

`firmware/xiao_integrado/` reúne los GPIO reales, calibración NVS, detector,
dos LED, BLE, telemetría y comandos `PING`/`RESET`. La app puede mostrar
flexión/contacto relativos y estado en vivo. Alex confirmó compilación objetivo
con Arduino CLI 1.6.0, core ESP32 3.3.12 y FQBN
`esp32:esp32:XIAO_ESP32C3`: diagnóstico BLE 608367 B de flash (46 %) y 17804 B
de RAM estática (5 %); integrado 639493 B (48 %) y 18396 B (5 %). Está
**compilado para XIAO, pero todavía no conectado, flasheado ni probado
físicamente**. El buzzer permanece deshabilitado hasta identificar tipo y
corriente.

**Verificación Flutter 24-11:** Alex ejecutó `flutter analyze`, `flutter test` y
`flutter build apk --debug` después de integrar telemetría: análisis sin
problemas, 8 pruebas aprobadas y APK debug construido. El teléfono todavía no
se conectó; instalación, permisos, BLE y recorrido manual permanecen pendientes.

## Fuente principal: protocolo BLE preparado por Codex
**Diagnóstico BLE**:
- Nombre anunciado: `HandSense-BLE-Lab` (solo si la versión local coincide).
- Control por característica GATT escribible: enviar **texto UTF-8** `HS1,C,PING`.
- Respuesta de ESP32 esperada en notificaciones: `HS1,A,PING,OK`.
- Tramas de eventos con versión y secuencia según `mobile/lib/data/handsense_protocol.dart`.
- **UUID exactos:** servicio `6c7a0001-8e2d-4f91-a6b5-3d3f7a120001`, eventos `6c7a0002-8e2d-4f91-a6b5-3d3f7a120001`, control `6c7a0003-8e2d-4f91-a6b5-3d3f7a120001`.

**ADVERTENCIA:** un laboratorio BLE anterior usaba `PING` → `ACK,PING` y `RATE=500`. **No es el protocolo vigente**. `app/PROTOCOLO.md` contiene primero el contrato BLE actual y después el HTTP histórico; no mezclarlos.

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
