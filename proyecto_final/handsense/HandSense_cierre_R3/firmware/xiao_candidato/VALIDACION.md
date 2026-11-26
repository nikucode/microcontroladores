# Variante candidata R3, 26/11/2026 — no certificada en hardware

Base: copia exacta del respaldo local (firmware/xiao_integrado). Pines, UUID, mensajes HS1 y política de secuencia conservados. Esta carpeta NO debe sobreescribir la base hasta superar compilación objetivo y ensayo de banco.

Cambios: extremo bajo del FSR admisible únicamente si la referencia de reposo calibrada es <=4 y la referencia activa es mayor; extremo alto sospechoso; referencias saturadas no se guardan; espera de filtro; invalidación del intento ante bloqueo y rearmado desde reposo sin perder totales; calibración fallida bloquea evaluación en la ejecución actual; ACK de RESET después de aplicar el reset, y manejo de solicitudes en loop. El buzzer permanece deshabilitado.

Limitaciones: un FSR descargado y uno desconectado pueden producir la misma lectura; el software no los distingue de manera inequívoca. El candidato no impide que una calibración anterior válida en NVS se cargue tras un reinicio después de una nueva captura fallida; verificar `v` y recalibrar antes de usar. No calibrar mientras la app tiene una sesión BLE abierta; desconectar y reconectar para evitar conflictos de secuencia. No se cambió Flutter. HS1 no incluye ID por solicitud, de modo que ACK tardíos idénticos aún pueden confundirse.

Pruebas de encabezados ejecutadas aquí:
```
g++ -std=c++17 -Wall -Wextra -Wpedantic -Wconversion -Werror \
  -fsanitize=address,undefined xiao_candidato_tests/test_regressions.cpp -o /tmp/hs_candidate_tests
ASAN_OPTIONS=detect_leaks=0 /tmp/hs_candidate_tests
```
Resultado: 17 grupos aprobados (14 históricos + interrupción y recuperación del detector, interrupción del contador flexivo y extremos ADC). LeakSanitizer desactivado. NO se compiló el sketch Arduino ni se ejecutaron pruebas de BLE físico o NVS físico del candidato.
