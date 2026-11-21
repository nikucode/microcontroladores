# Procedimiento para mantener HandSense autónomo en GitHub

## Regla principal
**GitHub debe responder seis preguntas sin conversaciones externas:** ¿qué es?, ¿qué piezas exactas se usan?, ¿cómo se conecta?, ¿cómo se ejecuta?, ¿qué se observó?, ¿qué falta y quién lo hace?

## Cada pieza adquirida
Actualizar `documentacion_actual/INVENTARIO_Y_COMPRA.md` con: nombre/modelo, fabricante, enlace o foto (si permiso), cantidad, fecha, precio pagado, tensión/corriente/rangos, pieza asignada y alternativa compatible. Separar: **propuesto / cotizado / comprado / recibido / probado / instalado**. Si una resistencia cambió de 47 kΩ a otro valor, documentar la medición que justificó el cambio y revisar esquema/código/afiche.

## Cada sesión de hardware
Guardar una nota en `validacion/` con fecha, autores, placa, montaje, fotos o diagrama, valores ADC crudos, voltajes referencia, evento esperado, observado, errores y conclusión. No subir fotos identificables sin consentimiento. Registrar cómo se alimentó el motor y qué driver exacto se utilizó.

## Cada cambio de firmware/app
- Confirmar `git status --short`, `git branch -vv` y `git fetch origin`.
- Guardar código fuente, dependencias con versión, tests y documentación de comandos.
- No subir `build/`, `.dart_tool/`, `.gradle/`, `android/local.properties`, claves, datos privados, boletas con información personal ni artefactos temporales.
- Mostrar qué pruebas se ejecutaron **realmente**. Declarar `pendiente` cuando no se ejecutaron.
- Si se cambia GPIO, UUID, unidad o formato de evento, actualizar simultáneamente firmware, app, esquema, tutorial y tabla de pruebas.
- Separar resultados simulados, calculados, en banco y en wearable.

## Roles y coordinación
Cote mantiene inventario, hardware, calibración, fotos del montaje y el tríptico integral. Alex mantiene firmware, Flutter/BLE, repositorio y evidencias digitales. Ambos revisan el esquema y explican el recorrido completo, con cambios registrados en `COORDINACION.md`.

## Estructura objetivo (no todos los directorios existen aún)
```text
proyecto_final/handsense/
├── README.md                  # orientación y lectura rápida
├── LEER_PRIMERO.md            # decisiones del momento
├── documentacion_actual/      # auditoría, tutorial, conexiones, Gantt, inventario
├── investigacion/             # antecedentes y límites de alcance
├── firmware/
│   ├── adquisicion/           # simulación histórica ESP32 clásico
│   ├── logica_gesto/          # detector histórico
│   └── ble_diagnostico/       # PENDIENTE subir desde Codex local
├── app/                       # interfaz web histórica HTTP
├── mobile/                    # PENDIENTE subir Flutter Android local
├── montaje/                   # .fzz y archivos de simulación, cuando existan
├── validacion/                # ensayos con referencia y fotos sin datos sensibles
├── afiche/                    # tríptico 77x55 editable / PDF cuando esté listo
├── historial/                 # copias de documentación sustituida
└── informe/                   # informe y fuentes
```

## Qué hacer ahora desde el computador de Alex
1. Comparar archivos: `git status --short`, `git fetch origin`, `git log --oneline --all -15`.
2. Revisar archivos `mobile/`, `firmware/ble_diagnostico/`, y contrato BLE. Copiar versiones finales, no cambiar UUID sin auditoría.
3. Identificar si existe `~/Downloads/Carta_Gantt_HandSense.ods`, conservarla en historial como fuente si no contiene datos personales.
4. Verificar `git status` y `.gitignore` antes de `git add` de subcarpetas. No incluir otros trabajos.
5. Incorporar inventario real, fotos de circuito y mediciones reales cuando existan.
6. Revisar fuentes, compilar donde sea posible y pedir revisión cruzada a Cote antes de fusionar.
