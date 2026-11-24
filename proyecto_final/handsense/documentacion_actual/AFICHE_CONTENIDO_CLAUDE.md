# Paquete de contenido para diseñar el tríptico HandSense en Claude

## Prompt para Claude

Diseña un tríptico científico editable para la Feria de Proyectos de Microcontroladores UNAB. Debe poder imprimirse sobre cartón piedra horizontal de **77 cm × 55 cm**, con ala izquierda de 19,25 cm, panel central de 38,5 cm y ala derecha de 19,25 cm. Marca guías de pliegue no imprimibles y deja libres los **10 cm inferiores del panel central**, porque allí quedará el prototipo.

Entrega primero una versión editable SVG o equivalente vectorial y luego PDF listo para imprenta. No rasterices textos. Usa español, poco texto, jerarquía legible a 1,5 m y contraste accesible. Título ≥140 pt, subtítulos 60–70 pt y cuerpo cercano a 40 pt, ajustando solo si la lectura física lo exige.

Identidad visual:

- Ciruela profundo `#33284E`.
- Lavanda tecnológica `#7565AB`.
- Fondo blanco lavanda `#F7F5FC`.
- Títulos Manrope o Poppins; contenido Inter o Atkinson Hyperlegible.
- Estética tecnológica, amable, editorial y científica; no clínica, corporativa ni infantil.
- Marca: **HandSense**.
- Eslogan: **Movimiento con sentido**.

Reglas de evidencia:

1. No inventes mediciones, porcentajes de precisión, errores, pruebas físicas, fotografías ni funciones.
2. Mantén los marcadores `[INSERTAR …]` visibles con fondo amarillo hasta que el equipo proporcione evidencia real.
3. La app web, ESP32 DevKit, Wi-Fi/HTTP y motor vibrador pertenecen a versiones históricas. La versión de feria usa XIAO ESP32-C3, BLE, dos LED y buzzer opcional condicionado por su tipo.
4. Los porcentajes de flexión/contacto son relativos a la calibración; no son grados ni newtons.
5. No describas HandSense como dispositivo médico ni afirmes eficacia terapéutica.
6. Usa **María José Córdoba**, no “Córdova”.

Archivos prioritarios adjuntos: rúbrica oficial, afiche de ejemplo, este documento, `RUBRICA_Y_AFICHE.md`, `ESTADO_TECNICO_Y_BLE.md`, `GUIA_PEDAGOGICA.md`, `AUDITORIA_CONSOLIDADA_2026-11-21.md`, esquema del montaje y capturas/fotos reales cuando estén disponibles.

## Encabezado

**HandSense**  
**Movimiento con sentido**  
Sistema vestible experimental para reconocer y explicar la pinza pulgar–índice

Alex Díaz · María José Córdoba  
Universidad Andrés Bello · Ingeniería en Automatización y Robótica · Microcontroladores · [INSERTAR SEDE] · 2026

## Ala izquierda — problema y objetivo

### ¿Flexionar un dedo es suficiente?

Una flexión aislada no demuestra que el pulgar y el índice hayan hecho contacto. Contar solo el movimiento puede confundir una flexión con una pinza completa.

### Nuestra pregunta

¿Qué información aporta combinar flexión y contacto frente a contar únicamente la flexión?

### Objetivo

Construir un prototipo vestible de bajo costo que observe ambas señales, reconozca la secuencia de pinza y explique por qué cada intento se contó, quedó incompleto o no pudo evaluarse.

**Ilustración solicitada:** dibujo sencillo de pulgar e índice con sensor flexivo dorsal y FSR en la zona de contacto. Rotular “flexión” y “contacto”; no usar anatomía médica compleja.

## Panel central — solución con microcontrolador

### ¿Cómo funciona?

Representar este diagrama horizontal con flechas grandes:

```text
Flexivo + FSR
sensores resistivos
        ↓
Divisores a 3,3 V
        ↓
ADC XIAO ESP32-C3
GPIO3 + GPIO4
        ↓
Filtro + calibración NVS
        ↓
Máquina de estados
flexión → contacto → liberación
        ├── LED verde: completa
        ├── LED ámbar: incompleta
        └── BLE ⇄ App Flutter
                 datos + comandos
```

Añadir alimentación: `USB 5 V → regulador de la placa → lógica y sensores a 3,3 V`. No dibujar sensores conectados a 5 V.

### Decisión de diseño clave

Dos divisores convierten resistencia en voltaje. El sistema registra reposo y pinza, normaliza cada canal entre 0 y 100 % y utiliza histéresis para evitar cambios falsos cerca del umbral.

```text
Vflex = 3,3 · Rflex / (47 kΩ + Rflex)
Vfsr  = 3,3 · 10 kΩ / (Rfsr + 10 kΩ)
```

La calibración se guarda en la memoria no volátil NVS del ESP32. La clasificación solo acepta la secuencia:

```text
REPOSO → FLEXIÓN → CONTACTO → LIBERACIÓN → REPOSO
```

Contacto primero, señales simultáneas o falta de liberación no se cuentan como repetición completa.

### Comunicación

BLE GATT transmite estado, flexión relativa, contacto relativo y eventos. La app responde con explicaciones y puede enviar `PING` para comprobar el enlace y `RESET` para reiniciar la sesión. No se necesita internet ni servidor local.

En la zona inmediatamente superior a los 10 cm libres colocar una flecha: **“Mira aquí abajo el prototipo funcionando”**.

## Ala derecha — evidencia y demostración

### Resultados

Crear esta tabla sin completar valores:

| Prueba | Referencia | HandSense | Error/resultado |
|---|---:|---:|---:|
| Voltaje flexivo en reposo | `[MULTÍMETRO V]` | `[ADC mV]` | `[ERROR %]` |
| Voltaje flexivo en pinza | `[MULTÍMETRO V]` | `[ADC mV]` | `[ERROR %]` |
| Voltaje FSR sin contacto | `[MULTÍMETRO V]` | `[ADC mV]` | `[ERROR %]` |
| Voltaje FSR con contacto | `[MULTÍMETRO V]` | `[ADC mV]` | `[ERROR %]` |
| Intentos clasificados | `[N OBSERVADOS]` | `[N CORRECTOS]` | `[RESULTADO]` |

Pie de tabla: “Resultados experimentales del montaje final; versión, condiciones y número de ensayos documentados.”

### Nuestra app

Reservar un marco vertical para `[INSERTAR CAPTURA REAL DE FLUTTER CON BLE]`. Al lado usar solo:

- Señales relativas en tiempo real.
- Estado del gesto.
- Intentos completos e incompletos.
- “Por qué se contó”.
- Comando confirmado por el ESP32.

### ¡Pruébalo tú!

1. Coloca el soporte y comienza con los dedos separados.
2. Une pulgar e índice y vuelve lentamente a reposo.
3. Observa los LED y la explicación en la app.

### Lo más difícil

**Problema:** la placa de simulación y el XIAO no comparten pines, y cada montaje produce rangos distintos.  
**Solución:** reasignamos GPIO, separamos la demostración de los datos reales y añadimos calibración individual, histéresis y pruebas de secuencias inválidas.

### Versión 2.0

Validar con más participantes, mejorar el soporte textil, estudiar la calibración de fuerza y conservar sesiones de forma persistente.

## Evidencia visual pendiente

- `[INSERTAR FOTO DEL PROTOTIPO FINAL]`.
- `[INSERTAR CAPTURA APP CONECTADA]`.
- `[INSERTAR TABLA DE MEDICIONES REALES]`.
- Opcional: QR al repositorio, solo si puede leerse y existe conexión; imprimir también la URL corta.

## Revisión obligatoria antes de exportar

- [ ] Medidas 77 × 55 cm y paneles 19,25 / 38,5 / 19,25 cm.
- [ ] Zona central inferior de 10 cm vacía.
- [ ] Título, problema, objetivo, diagrama de bloques, alimentación, App y resultados visibles.
- [ ] Dos sensores analógicos y dos actuadores identificados.
- [ ] BLE bidireccional indicado sin afirmar validación si aún no existe evidencia.
- [ ] Tabla completada únicamente con mediciones reales y unidades.
- [ ] Captura y fotografía pertenecen a la versión final.
- [ ] Ningún texto dice grados, newtons, precisión o eficacia clínica sin respaldo.
- [ ] Legible al imprimir una prueba a escala y observarla a 1,5 m.
- [ ] Ortografía de nombres, UNAB, sede y fecha revisada.
