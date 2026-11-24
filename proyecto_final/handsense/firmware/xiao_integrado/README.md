# Firmware XIAO integrado — candidato para banco

**Estado:** implementado y revisado estáticamente; pendiente de compilar y probar en la placa física.

Integra pines XIAO, calibración persistente, detector estricto, dos LED, BLE, telemetría y comandos. No reemplaza las simulaciones históricas.

## Cableado

- Flexivo: divisor `3V3 → 47 kΩ → D1/GPIO3 → flexivo → GND`.
- FSR: divisor `3V3 → FSR → D2/GPIO4 → 10 kΩ → GND`.
- LED completo: D4/GPIO6 → 330 Ω → ánodo; cátodo a GND.
- LED incompleto: D5/GPIO7 → 330 Ω → ánodo; cátodo a GND.
- Buzzer D3/GPIO5: **deshabilitado por defecto**. No conectarlo hasta identificar tipo y corriente. Un buzzer magnético o parlante necesita transistor.

## Primera prueba

1. Seleccionar `XIAO_ESP32C3` en Arduino IDE y compilar el sketch.
2. Cargarlo y abrir monitor serie a 115200.
3. Sin buzzer, comprobar los LED.
4. Enviar `r` en reposo y `p` manteniendo una pinza; `v` muestra la calibración.
5. En nRF Connect habilitar notificaciones y probar `HS1,C,PING` y `HS1,C,RESET`.
6. Instalar la app y comprobar porcentajes relativos, estado, eventos y ambos comandos.

Las tramas de telemetría son `HS1,T,<flex%>,<contacto%>,<estado>`. Los porcentajes dependen de la calibración y no equivalen a grados ni newtons.
