# HandSense

Proyecto de **Alex Díaz y María José Córdoba** para Microcontroladores (UNAB). HandSense es un prototipo experimental vestible que combina flexión y contacto para estudiar una pinza pulgar–índice, explicar su clasificación y comunicar eventos a una aplicación Android. No es un dispositivo clínico ni mide fuerza o ángulo sin calibración.

## Ruta de lectura

1. [Estado vigente y prioridades](LEER_PRIMERO.md).
2. [Auditoría consolidada](documentacion_actual/AUDITORIA_CONSOLIDADA_2026-11-21.md): matriz, contradicciones y estado Git.
3. [Guía pedagógica](documentacion_actual/GUIA_PEDAGOGICA.md): sensores → divisor → ADC → algoritmo → actuadores → BLE → Flutter.
4. [Reproducibilidad](documentacion_actual/REPRODUCIBILIDAD.md): comandos, resultados esperados y diagnóstico.
5. [Cronología y decisiones](documentacion_actual/CRONOLOGIA_Y_DECISIONES.md): septiembre–noviembre con vacíos explícitos.
6. [Montaje XIAO](documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md), [inventario](documentacion_actual/INVENTARIO_Y_COMPRA.md) y [validación](validacion/PROTOCOLO_Y_CIERRE.md).
7. [Gantt vigente](documentacion_actual/GANTT_VIGENTE.md) y [rúbrica/tríptico](documentacion_actual/RUBRICA_Y_AFICHE.md).

## Qué existe

- `firmware/adquisicion/`: simulación histórica ESP32 DevKit con GPIO34/35.
- `firmware/logica_gesto/`: filtro, histéresis, detector estricto y pruebas C++.
- `firmware/ble_diagnostico/`: transporte GATT mínimo `PING`/`ACK`, preparado pero no probado en placa.
- `mobile/`: aplicación Flutter Android con demostración separada de BLE, cuatro secciones y pruebas.
- `app/`: demostración web histórica con datos simulados; no es la app móvil vigente.
- `validacion/`: BOM provisional, protocolo y plantilla vacía de ensayos físicos.
- `investigacion/` e `informe/`: antecedentes fechados; pueden contener decisiones reemplazadas.

## Estado comprobado al 21/11/2026

- **Verificado en software:** 9 pruebas C++; 5 pruebas JavaScript; Flutter `analyze` limpio, 7 pruebas aprobadas y APK debug compilado por Alex.
- **Simulado:** adquisición y dos escenarios de gesto en Wokwi con ESP32 DevKit.
- **Implementado sin validar físicamente:** BLE Flutter, firmware BLE diagnóstico y netlist preliminar XIAO.
- **Pendiente:** inventario físico exacto, firmware integrado XIAO, telemetría continua, sensores/ADC calibrados, motor/driver, BLE real, montaje vestible y ensayos.

La feria está documentada para el **27/11/2026**. Los planes titulados “25 NOV” y el póster A1 se conservan solo como historia; el formato vigente es tríptico horizontal de **77 × 55 cm**.
