# HandSense — proyecto final de Microcontroladores

**Autores:** Alex Díaz y María José Córdoba («Cote») · **Universidad Andrés Bello** · Ingeniería en Automatización y Robótica.  
**Fecha del corte documental:** 20 de noviembre de 2026. **Feria oficial:** 27 de noviembre de 2026, 09:00–13:00.

> **Comienza por [LEER_PRIMERO.md](LEER_PRIMERO.md)**. Esta es la portada; el documento anterior se conserva en [historial/README_2026-11-10.md](historial/README_2026-11-10.md).

## El proyecto en un párrafo
HandSense es un **prototipo experimental**, no clínicamente validado, diseñado para observar una **pinza pulgar–índice** combinando dos señales analógicas: flexión resistiva y contacto mediante FSR402. Un XIAO ESP32-C3 debe procesarlas, activar señales visuales y hápticas y comunicarse por **BLE** con una aplicación Flutter Android que explica por qué se contó o no un intento. La innovación propuesta se estudia mediante comparación del conteo basado solo en flexión con el conteo combinado; **no hay aún prueba física ni clínica suficiente para afirmar superioridad**.

## ¿Por dónde empezar?
| Necesidad | Documento |
|---|---|
| Saber qué se decidió y qué falta | [LEER_PRIMERO](LEER_PRIMERO.md) |
| Entender paso a paso el sistema | [Guía pedagógica](documentacion_actual/GUIA_PEDAGOGICA.md) |
| Consultar componentes exactos y cantidades | [Inventario y compra](documentacion_actual/INVENTARIO_Y_COMPRA.md) |
| Cablear sin confundir pines ni voltajes | [Montaje XIAO](documentacion_actual/MONTAJE_Y_CONEXIONES_XIAO.md) |
| Ver qué código existe y qué se probó | [Reproducción de pruebas](documentacion_actual/REPRODUCIBILIDAD.md) |
| Distinguir diseño, evidencia y riesgos | [Auditoría documental](documentacion_actual/AUDITORIA_REPOSITORIO_2026-11-20.md) |
| Entender cambios desde septiembre | [Cronología y decisiones](documentacion_actual/CRONOLOGIA_Y_DECISIONES.md) |
| Revisar responsabilidades y fechas | [Coordinación](documentacion_actual/COORDINACION.md), [Gantt integral septiembre–noviembre](documentacion_actual/GANTT_INTEGRAL.md) y [Gantt de cierre](documentacion_actual/GANTT_VIGENTE.md) |
| Entender qué exige el profesor | [Rúbrica y tríptico](documentacion_actual/RUBRICA_Y_AFICHE.md) |
| Ayudar a mantener GitHub autosuficiente | [Reglas de documentación](documentacion_actual/COMO_ACTUALIZAR_REPOSITORIO.md) |

## Código publicado vs. código local
| Componente | En GitHub main, a fecha de corte | Estado |
|---|---|---|
| [Adquisición inicial ESP32 clásico](firmware/adquisicion/) | Sí | Simulación de potenciómetros |
| [Gestos e histéresis](firmware/logica_gesto/) | Sí | Fuente y cinco casos C++; no garantiza orden estricto |
| [Aplicación web histórica](app/) | Sí | Demostración web local con escenarios, **no es Flutter final** |
| `mobile/` Flutter Android | **No** | Existe en computador según Codex, siete pruebas pasan y APK compila |
| `firmware/ble_diagnostico/` | **No** | Preparado localmente según Codex, hardware sin verificación |
| Fritzing `.fzz` definitivo | **No** | Netlist y planos preliminares, falta circuito materializado |

**Advertencia:** `app/PROTOCOLO.md` es un **contrato histórico HTTP/Wi-Fi**, no el contrato BLE final. Los UUID GATT y código local deben recuperarse del computador y versionarse antes de afirmar que la reproducción está completa.

## Evidencias y honestidad experimental
- **Simulado:** potenciómetros en Wokwi y eventos completos/incompletos específicos.
- **Probado por software:** pruebas C++ y Flutter registradas en sesiones Codex; la app Android BLE actualizada compiló.
- **No acreditado físicamente aún en este repositorio:** lecturas de sensores reales, motor seguro, telemetría BLE real, persistencia de calibración, soporte vestible y medición de errores instrumentales.
- No presentar porcentajes de ADC como grados o newtons sin calibración con referencia.
- Fecha de documento ≠ fecha de experimento; cada evidencia debe registrar ambas si difieren.

## Requisitos docentes
Feria del **27-11-2026**. 2 sensores analógicos, al menos 2 actuadores, ADC del ESP32 configurado/calibrado, comunicación bidireccional con app, estructura de código, mediciones comparadas y error. El afiche obligatorio es un **tríptico en cartón piedra de 77 × 55 cm (19,25/38,5/19,25 cm)**, no A1.

## Documentación histórica
Las decisiones tempranas, avances y alternativas se mantienen en [PLAN_DE_TRABAJO.md](PLAN_DE_TRABAJO.md), [PLAN_ENTREGA_25_NOV.md](PLAN_ENTREGA_25_NOV.md), [SEGUIMIENTO_NOVIEMBRE.md](SEGUIMIENTO_NOVIEMBRE.md), [RUTA_SIN_HARDWARE.md](RUTA_SIN_HARDWARE.md), [investigacion/](investigacion/), [informe/](informe/) y [app/](app/). **Antes de ejecutar una recomendación antigua, contrástala con LEER_PRIMERO.**

**Principio:** código versionado + circuito identificable + BOM real + procedimiento + resultados observados + limitaciones. Sin estos elementos, un repositorio puede estar bien escrito y seguir sin ser reproducible.
