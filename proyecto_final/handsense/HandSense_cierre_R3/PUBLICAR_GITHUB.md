# Publicación selectiva al terminar pruebas

En el repositorio real, desde `~/Documents/Github/microcontroladores/proyecto_final/handsense`:
```
git status --short -- .
git diff --stat -- .
git log --oneline origin/main..HEAD
git diff --check -- .
```
La copia auditada contiene tres commits locales sin publicar, cambios del firmware y Flutter y muchos archivos auxiliares no registrados. No ejecutar `git add .` en la raíz general. Incorporar documentos finales en rutas propias de HandSense y el candidato solo tras revisión; conservar base. Verificar `git status --short` y revisar los archivos preparados. Ejemplo de selección (adaptar según cambios reales y confirmar archivos):
```
git add -- firmware/ble_diagnostico firmware/xiao_integrado firmware/xiao_integrado_tests
git add -- mobile/lib mobile/test mobile/assets mobile/pubspec.yaml mobile/pubspec.lock
git add -- documentacion_actual/ESTADO_TECNICO_Y_BLE.md documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md documentacion_actual/REPRODUCIBILIDAD.md
git diff --cached --stat
git diff --cached --check
```
Antes de commit: comprobar que `git diff --cached --name-only` no muestra `desafio_pic` ni otros proyectos, que tampoco existen otros archivos previamente en staging y que no hay secretos. Añadir de forma explícita los PDF y fuentes propios que se vayan a publicar; no publicar la plantilla institucional, materiales de clase, chats, HTML guardado de Claude ni fotos personales no autorizadas. No subir APK debug como si fuera binario estable. Después de confirmar contenido, `git commit -m "Cerrar integración y documentación de HandSense"`, `git fetch origin`, comprobar divergencia y `git push origin main` solo si no se requiere reconciliar commits y se autoriza la publicación. No force push. Verificar GitHub, reproducibilidad y que HEAD corresponde a lo realmente probado.
