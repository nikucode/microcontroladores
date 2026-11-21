# Carta Gantt operativa — HandSense — CORTE 20-11-2026

**Fecha oficial feria:** **D0 = viernes 27-11-2026, 09:00–13:00**. Se reemplazan las fechas tentativas 23/25-11 de planes anteriores. **No es un compromiso de trabajo diario.** Bloques flexibles sujetos a clases, otras entregas y compromisos de fin de semana.

**Fuente recuperada:** `SEGUIMIENTO_NOVIEMBRE.md` (corte 10-11; H1–H9) y `PLAN_ENTREGA_25_NOV.md` (plan histórico). La carta original de septiembre `~/Downloads/Carta_Gantt_HandSense.ods` **fue mencionada pero NO recuperada**, por lo tanto esta Gantt no reproduce su contenido.

**Estado**: ✅ comprobado en software/simulación; ◐ preparado sin prueba física; ☐ pendiente; ? dato/inventario sin confirmar.

| ID | Entregable e hito verificable | Responsable principal | Ventana flexible | Estado al 20-11 | Prueba de cierre |
|---|---|---|---|---|---|
| G1 | Confirmar inventario REAL, placa/motor/driver, precios y disponibilidad | Cote | 20–22 nov | ? | Tabla con fotos/modelos y comprados |
| G2 | Unificar pines, divisores y esquema de montaje, Fritzing y mesa | Cote | 20–23 nov | ◐ diseño netlist; .fzz pendiente | Esquema + protoboard sin cortos |
| G3 | Conservar pruebas de lógica y configurar firmware XIAO ADC/LED | Alex | 20–24 nov | ◐ 9 pruebas pasan; integración XIAO pendiente | GPIO reales y lecturas en serie |
| G4 | Publicar código Flutter/BLE local y contrato GATT | Alex | 20–23 nov | ✅ fuente y pruebas en `main`; APK compilado | archivos + tests + UUID coherentes |
| G5 | Ejecutar BLE real con nRF Connect y Flutter (`PING/ACK`) | Alex | 21–24 nov | ☐ | log/video de respuesta real |
| G6 | Probar flex/FSR, voltajes y ADC vs multímetro | Cote | 21–25 nov | ☐ | CSV con rango y error |
| G7 | Probar LED, driver y motor independientemente | Cote | 21–25 nov | ☐ | video + corriente/tensión |
| G8 | Integrar firmware, sensores y app; detectar pinza completa/incompleta | Ambos | 23–26 nov | ☐ | prueba conjunta, sin falsos datos |
| G9 | Calibrar, ensayar reconexión/reinicio, preparar pruebas comparativas | Ambos | 24–26 nov | ☐ | medición etiquetada y evidencias |
| G10 | Afiche tríptico 77×55 completo, con espacios de datos actualizables | Cote | 20–26 nov | ◐ A1 anterior no sirve como formato final | tríptico impreso, estable y legible |
| G11 | Matriz rúbrica, documentación y respaldo GitHub actualizados | Alex | 20–26 nov | ◐ parcial | enlaces, fotos, resultados, inventario |
| G12 | Ensayo general y congelar versión estable | Ambos | 26 nov | ☐ | APK/firmware respaldados, stand y demo |
| G13 | Feria | Ambos | **27 nov 09:00–13:00** | ☐ | demo y afiche |

## Camino crítico y contingencia
**Camino crítico:** componentes → divisor/ADC + motor driver → firmware XIAO → BLE real → integración completa → ensayo. Pueden simular y diseñar sin esperar sensores. Si el montaje vestible se retrasa, **usar mesa ordenada como respaldo**, dejando explícita la limitación. Si BLE falla, mostrar registros y simulación, sin alegar cumplimiento de conexión física.

**Intercambios:** revisión asíncrona cuando cada paquete esté listo; **un intercambio técnico** antes de integración y **uno de evidencias** antes de afiche; al menos **una sesión conjunta real** antes de D0.

**Actualización:** registrar fecha, evidencia, dueño, bloqueo y próximo paso tras cada bloque trabajado; NO estimar progreso por porcentajes arbitrarios.
