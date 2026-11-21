# Auditoría técnica, pedagógica y documental — 20/11/2026

**Alcance:** directorio `proyecto_final/handsense/` de la rama `main`, inspeccionado el 20 de noviembre. **La revisión no equivale a compilar ni ejecutar hardware;** GitHub público no muestra los archivos locales sin push. Se inspeccionó también la estructura raíz para localizar el proyecto.

## 1. Diagnóstico ejecutivo
El proyecto publicado tiene **51 entradas Git (incluidas carpetas)** en HandSense al inicio de esta auditoría, con documentación inicial, investigación, firmware de adquisición y gestos, una demostración web, informe y protocolos. **Está incompleto como fuente única de continuidad** porque faltan los archivos móviles y BLE actuales, resultados físicos y montajes editables. El repositorio raíz incluye otros trabajos del ramo que no deben alterarse.

| Dimensión | Evidencia examinada | Estado | Acción de cierre |
|---|---|---|---|
| Identidad y acceso | README viejo + LEER_PRIMERO | Parcial | README nuevo con ruta de lectura |
| Cronología septiembre–noviembre | Seguimiento 10/11, investigación 28/10, registros Codex | Parcial | Separar fechas constatadas y rangos reconstruidos; archivar Gantt original si se encuentra |
| Componentes/BOM | validacion/BOM.csv + inventario actual | Parcial | Agregar boleta/fotos/part numbers reales, precios y cantidad en stock |
| Arquitectura y pinout | firmware ESP32 clásico + netlist XIAO | Parcial | Incorporar .fzz real, esquema y pruebas con multímetro |
| Firmware de adquisición | sketch Wokwi 34/35 | Publicado histórico | Adaptar al XIAO sin sobrescribir Wokwi histórico |
| Máquina de estados | gesture_logic.h + test_logic.cpp | Código y 5 casos | Resolver órdenes simultáneos/invertidos, señal inválida y umbrales reales |
| App web demostrativa | app/ | Publicado, histórico | Etiquetar explícitamente; no confundir con Android |
| App Flutter | ausente en main | **Crítico** | Publicar fuentes locales, pubspec, tests y Gradle reproducible |
| BLE | ausente firmware BLE main; contrato HTTP viejo | **Crítico** | Publicar firmware + UUID + tipos de tramas + instrucciones nRF Connect |
| Calibración física | validacion/ensayos.csv vacío | **Crítico** | Medir ADC/multímetro, referencia angular, FSR relativo o calibrado |
| Pruebas y resultados | C++ 5 casos, JS tests, logs Flutter locales | Parcial | Añadir instrucciones y resultados con fecha/versiones; no afirmar validación de hardware |
| Informe, afiche y Gantt | informe/avance.*, pauta docente resumida, Gantt corta | Parcial | Anexar Gantt integral, tríptico 77×55 y evidencia final |
| Pedagogía | pasos dispersos en README y avance.tex | Parcial | Guía de aprendizaje central y reproducción |

## 2. Contradicciones materialmente relevantes

1. **Comunicación:** `app/PROTOCOLO.md`, `validacion/PROTOCOLO_Y_CIERRE.md` y `PLAN_ENTREGA_25_NOV.md` describen Wi-Fi/HTTP, mientras que el diseño vigente eligió **BLE GATT**. **Acción:** conservar HTTP como antecedente histórico, etiquetarlo y publicar UUID/mensajes exactos desde Codex.
2. **Controlador:** `firmware/adquisicion/sketch.ino` y `firmware/logica_gesto/sketch.ino` usan **GPIO34/35, 18/19 del ESP32 clásico**; el XIAO ESP32-C3 elegido propone GPIO3/4, 6/7 y GPIO21 (motor condicionado). No cargar el firmware histórico sin adaptación.
3. **Fecha:** README antiguo y seguimiento 10/11 citan fecha provisional 23/25 de noviembre; la **rúbrica vigente** indica **27/11/2026, 09:00–13:00**.
4. **Afiche:** el diseño exploratorio A1 no cumple la pauta docente: **cartón piedra tríptico 77×55, paneles 19,25/38,5/19,25**, 10 cm inferiores centrales libres.
5. **Nombre:** documentos históricos alternan María José **Córdova**; Alex solicitó usar en los entregables nuevos **María José Córdoba**. Conservar el texto histórico como evidencia de época sin propagar la grafía antigua a nuevos materiales.
6. **Lógica:** `GestureDetector::update` acumula `seenFlex_` y `seenContact_`; puede declarar `COMPLETA` al regresar a reposo tras contacto primero, o con activación simultánea. Esto **no garantiza el orden de movimiento estricto** mencionado en documentos recientes; requiere decisión formal y nuevas pruebas.
7. **Tiempo de gesto:** el firmware publicado aún fija `ATTEMPT_TIMEOUT_MS = 3000`, mientras los ensayos manuales Wokwi reportaron ventana extendida para depuración. Distinguir versionado local/histórico y no atribuir una sola configuración a todas las pruebas.
8. **Inventario:** `validacion/BOM.csv` refleja cotizaciones de noviembre 10 y un solo LED; la versión actual propone dos LED y motor, con compras reales sin inventario confirmado.
9. **Persistencia:** documentos prometen EEPROM/calibración, pero no hay prueba versionada que demuestre almacenamiento y recuperación en el XIAO.

## 3. Evaluación de autonomía documental
Un visitante **sí puede**: comprender motivación, ver algoritmos históricos y ejecutar pruebas C++ con compilador, recorrer una app web demostrativa, consultar bibliografía y conocer la rúbrica resumida.  
Un visitante **no puede todavía**: obtener el APK Android a partir del código publicado, cargar el firmware BLE actual, obtener UUID GATT correctos, replicar el cableado con pieza de Fritzing definitiva, comprar **exactamente** lo que posee el equipo ni reproducir ensayos físicos. No atribuir estas posibilidades al repositorio.

## 4. Riesgos priorizados
- **P0 — Reproducibilidad:** Flutter/BLE locales ausentes en remoto.
- **P0 — Integración:** contrato BLE exacto ausente, incompatibilidad posible con laboratorio BLE anterior `PING`/ `ACK,PING`.
- **P0 — Seguridad:** etapa de motor requiere modelo, corriente y fuente definitivos.
- **P1 — Exactitud:** reglas de máquina de estados, unidades físicas/ADC, calibración y evidencia.
- **P1 — Entrega:** Gantt histórica y tríptico a fecha oficial.
- **P2 — Editorial:** índice único, glosario y referencias cruzadas.

## 5. Recomendación de cierre
1. No sobrescribir documentos fechados. Añadir encabezados **HISTÓRICO** en los que contienen decisiones abandonadas.
2. Publicar desde computador `mobile/`, firmware BLE y protocolo local, excluyendo build/.dart_tool/local.properties/secrets.
3. Completar inventario real con identificación física, valores, cantidad y estado; registrar sustituciones.
4. Integrar XIAO en mesa y validar mediciones, motor y BLE bidireccional.
5. Convertir resultados a evidencias mínimas con procedencia (versión/circuito/tipo de prueba); entregar Gantt integral y tríptico.
6. Mantener LEER_PRIMERO y README como entradas permanentes.

## 6. Método de inspección
Se consultaron el árbol `git/trees/main?recursive=1`, archivos `README`, `PLAN_DE_TRABAJO`, `SEGUIMIENTO_NOVIEMBRE`, `app/PROTOCOLO`, `firmware/adquisicion`, `firmware/logica_gesto`, `validacion`, `investigacion`, `informe/avance.tex` y `documentacion_actual`. No se inventaron resultados de ejecución ni se realizaron cambios físicos.
