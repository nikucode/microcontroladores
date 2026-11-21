# HANDSENSE — LEER PRIMERO (20-11-2026)

**Equipo:** Alex Díaz y María José Córdoba («Cote»). **Asignatura:** Microcontroladores, UNAB. **Feria:** **viernes 27 de noviembre de 2026, 09:00–13:00**, según rúbrica entregada por el docente.

> **Documento de continuidad para consultar desde cualquier celular sin acceso a nuestros chats.** Si ves una contradicción entre documentos antiguos y esta carpeta, revisa el estado y la fuente aquí; no interpretes una propuesta como medición.

## En cinco minutos
- **Objetivo:** prototipo experimental vestible para clasificar secuencias de pinza pulgar–índice: flexión + contacto + liberación, con explicación del resultado; no dispositivo clínico validado.
- **Placa elegida:** **Seeed Studio XIAO ESP32-C3** (con antena), 3,3 V, BLE. El ESP32 DevKit de simulación utilizaba GPIO34/35 y **NO** comparte el pinout.
- **Dos entradas:** sensor flexivo 2,2" y FSR402, mediante divisores resistivos a 3,3 V.
- **Salidas:** LED verde, LED ámbar y motor vibrador mediante etapa de control; motor **sin conectar hasta comprobar modelo, alimentación y driver**. Dos LED ya satisfacen dos salidas actuadoras en el sentido literal, pero la propuesta comprometió también vibración.
- **App:** Flutter Android publicada en `main`. Alex verificó análisis limpio, **7 pruebas Flutter aprobadas y APK de depuración compilado**; no confundir con BLE físicamente confirmado.
- **Comunicación elegida:** BLE GATT y diagnóstico con nRF Connect; **no** Wi-Fi HTTP del documento histórico app/PROTOCOLO.md.
- **Pruebas de simulación:** pinza completa y flexión sin contacto observadas en Wokwi; pruebas reales de sensores/driver/BLE integrados **sin evidencia verificada disponible aquí**.
- **Rúbrica:** funcionamiento 25 %, ADC 20 %, código 20 %, BLE/app 15 %, montaje/Gantt 10 %, tríptico/stand 10 %.
- **Tríptico:** **77 × 55 cm, horizontal, 19,25 / 38,5 / 19,25 cm**, cartón piedra; 10 cm inferiores del panel central despejados. **NO A1**.

## Índice de continuidad
1. [Inventario exacto y compra](documentacion_actual/INVENTARIO_Y_COMPRA.md): función, valor, cantidad, qué sabemos y qué falta verificar.
2. [Montaje y conexiones XIAO](documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md): cableado y medidas de seguridad.
3. [Estado real y protocolo BLE](documentacion_actual/ESTADO_TECNICO_Y_BLE.md): versiones, evidencia, contratos incompatibles y pendientes.
4. [Carta Gantt vigente](documentacion_actual/GANTT_VIGENTE.md) y [tabla CSV](documentacion_actual/GANTT_VIGENTE.csv).
5. [Coordinación Alex y Cote](documentacion_actual/COORDINACION.md).
6. [Rúbrica, tríptico y entrega](documentacion_actual/RUBRICA_Y_AFICHE.md).
7. [Evidencias y próximos pasos](documentacion_actual/EVIDENCIAS_Y_PENDIENTES.md).

## Prioridad al retomar
1. Confirmar inventario **real comprado y disponible** (no confundir una cotización con una compra).
2. Instalar el APK BLE ya compilado y registrar el recorrido manual en el teléfono.
3. Validar placa sin sensores: BLE anuncio → `PING/ACK` → Flutter.
4. Montar ADC/LED en mesa y medir señales; motor separado; integrar.
5. Sustituir evidencias simuladas del tríptico con resultados reales, imprimir y ensayar.

## Nota de procedencia
Esta carpeta reúne decisiones de trabajo y resúmenes de sesiones Codex al 19–20 de noviembre. Los datos históricos permanecen en documentos previos. **NO constituye validación física**. El archivo original de septiembre `~/Downloads/Carta_Gantt_HandSense.ods` fue citado en una bitácora, pero no se consiguió recuperar aquí: esta Gantt es una **actualización operativa**, no una edición de ese archivo.
