# Contrato entre ESP32 y app

## Transporte vigente: BLE GATT v1 — 18 de noviembre de 2026

Esta sección reemplaza al transporte HTTP como camino principal. Su
implementación Flutter está preparada, pero aún no se ha probado con el ESP32
físico. Los UUID son parte del contrato y deben copiarse exactamente al
firmware:

| Elemento | UUID | Operación |
|---|---|---|
| Servicio HandSense | `6c7a0001-8e2d-4f91-a6b5-3d3f7a120001` | Anunciar y descubrir |
| Eventos | `6c7a0002-8e2d-4f91-a6b5-3d3f7a120001` | ESP32 notifica; teléfono se suscribe |
| Control | `6c7a0003-8e2d-4f91-a6b5-3d3f7a120001` | Teléfono escribe con respuesta |

Nombre anunciado esperado: `HandSense` o un nombre que comience por
`HandSense`.

Los mensajes son UTF-8 compactos, sin salto de línea, y no superan 20 bytes:

```text
HS1,E,<secuencia>,C     completa
HS1,E,<secuencia>,NC    sin contacto
HS1,E,<secuencia>,NF    sin flexión
HS1,E,<secuencia>,NR    sin liberación
HS1,E,<secuencia>,U     no evaluable
```

`secuencia` es un entero no negativo que permite descartar notificaciones
repetidas dentro de una conexión. `U` solo debe emitirse cuando el firmware
realmente detecte una señal no evaluable; no es sinónimo de movimiento
incompleto.

La primera orden bidireccional es:

```text
Teléfono → Control: HS1,C,PING
ESP32 → Eventos:    HS1,A,PING,OK
```

La app solo informa que el ESP32 confirmó la orden si recibe el `ACK` en menos
de tres segundos. Que Android acepte la escritura GATT no se considera una
confirmación del firmware.

## Contrato HTTP histórico

**Estado:** propuesta anterior conservada como antecedente; ya no es el camino
principal. El firmware calcula estados y eventos; la app solo los muestra.
Todos los porcentajes son relativos a la calibración de cada montaje, no
unidades clínicas.

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

`timestamp_ms` es milisegundos desde Unix si el ESP32 tiene reloj sincronizado; si no lo tiene, usar milisegundos desde el arranque y documentarlo. La app actualmente no muestra este campo. `flexion_pct` y `contacto_pct` deben estar entre 0 y 100; `repeticiones` e `incompletos` son enteros no negativos. `estado` admite `REPOSO`, `FLEXION`, `CONTACTO`, `LIBERACION`, `ESPERA_REPOSO`, `ERROR_SENAL`. `calibracion` admite `LISTA`, `PENDIENTE`, `INVALIDA`. Los códigos actuales de `ultimo_evento` son `NINGUNO`, `COMPLETA`, `SIN_CONTACTO`, `SIN_FLEXION`, `SIN_LIBERACION`, `SENAL_NO_CONFIABLE`. `detalle` es una explicación breve y legible. El firmware podrá agregar campos sin romper la app; los cambios de significado o estructura requieren incrementar `schema`.

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

## Presentación de lecturas (10 de noviembre)

ESPERA_REPOSO indica que el intento terminó y se espera liberar ambas entradas. La app oculta porcentajes cuando falta conexión, calibración válida o el firmware informa ERROR_SENAL. Esto no implementa bloqueo en el microcontrolador: ese requisito sigue pendiente. Tras reconectar, los contadores son los informados por el ESP32.
