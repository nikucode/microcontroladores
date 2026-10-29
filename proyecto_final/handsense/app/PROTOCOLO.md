# Contrato inicial entre ESP32 y app

**Estado:** propuesta de integración, pendiente de implementar y verificar en hardware. El firmware calcula estados y eventos; la app solo los muestra. Todos los porcentajes son relativos a la calibración de cada montaje, no unidades clínicas.

## Leer estado

`GET /api/estado` → HTTP 200, `Content-Type: application/json`, sin caché:

```json
{
  "schema": 1,
  "timestamp_ms": 1700000000000,
  "flexion_pct": 76,
  "contacto_pct": 72,
  "estado": "CONTACTO",
  "calibracion": "LISTA",
  "repeticiones": 3,
  "incompletos": 1,
  "ultimo_evento": {
    "codigo": "COMPLETA",
    "detalle": "Flexión y contacto detectados; después hubo liberación y retorno a reposo."
  }
}
```

`timestamp_ms` es milisegundos desde Unix si el ESP32 tiene reloj sincronizado; si no lo tiene, usar milisegundos desde el arranque y documentarlo. La app actualmente no muestra este campo. `flexion_pct` y `contacto_pct` deben estar entre 0 y 100; `repeticiones` e `incompletos` son enteros no negativos. `estado` admite `REPOSO`, `FLEXION`, `CONTACTO`, `LIBERACION`, `ERROR_SENAL`. `calibracion` admite `LISTA`, `PENDIENTE`, `INVALIDA`. Los códigos actuales de `ultimo_evento` son `NINGUNO`, `COMPLETA`, `SIN_CONTACTO`, `SIN_FLEXION`, `SIN_LIBERACION`, `SENAL_NO_CONFIABLE`. `detalle` es una explicación breve y legible. El firmware podrá agregar campos sin romper la app; los cambios de significado o estructura requieren incrementar `schema`.

## Enviar acciones

`POST /api/acciones`, `Content-Type: application/json`:

```json
{"accion":"reiniciar_sesion"}
```

o

```json
{"accion":"calibrar"}
```

Respuesta esperada: HTTP 200 y `{"ok":true}`. Si la acción no puede ejecutarse, responder con código HTTP de error y `{"ok":false,"error":"explicación"}`. La calibración debe ser una operación explícita del firmware: no asumir que presionar el botón produce una calibración válida. Los umbrales y el procedimiento se definirán a partir de señales medidas.

## Integración prevista

1. Implementar el algoritmo y verificarlo por monitor serie con entradas simuladas.
2. Exponer las mismas variables en `GET /api/estado`.
3. Servir los archivos de `app/` desde el ESP32 y probar desde un teléfono conectado a su red Wi‑Fi.
   Los módulos `.js` deben enviarse con un tipo MIME de JavaScript válido.
4. Implementar `POST /api/acciones` y confirmar que los cambios aparecen en el estado y en el monitor serie.
5. Probar desconexión/reconexión y concordancia entre app, LED, vibración y registro serie.

La app no recibe datos personales ni los envía a un servidor externo. Evitar incluir nombre u otros datos identificables en el JSON mientras no sean necesarios.
