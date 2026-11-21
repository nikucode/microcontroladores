# Rúbrica oficial y afiche tríptico — requisitos comprobables

**Feria:** viernes **27 de noviembre de 2026, 09:00–13:00** (rúbrica del docente).

| Criterio | Peso | Evidencia para excelente |
|---|---:|---|
| Funcionamiento y mínimos | 25 % | Estabilidad durante demo, **2 sensores analógicos, 2 actuadores y comunicación inalámbrica con app** |
| Sensores y ADC | 20 % | Configuración ADC correspondiente al ESP32 (aclaración verbal del docente), convertir lecturas a magnitudes físicas justificadas, comparar con instrumento y **reportar error** |
| Programación | 20 % | Código modular según diagrama de bloques y comentado; equipo explica funcionamiento |
| BLE / aplicación | 15 % | Enlace estable, **datos reales en tiempo real** y **al menos un comando/ajuste app→ESP32** |
| Montaje y planificación | 10 % | Firme, seguro, alimentaciones adecuadas/separadas, cables identificados, diagrama + Gantt coherentes |
| Afiche y stand | 10 % | Formato correcto, legible a 1,5 m, problema + bloques + app + resultados; stand ordenado |

## Formato que sustituye al póster A1 previo
- **Cartón piedra 55×77 cm** (ideal 5 mm, 3 mm aceptable), **horizontal: 77 ancho × 55 alto**.
- Alas izquierda/derecha **19,25 cm**, centro **38,5 cm** (proporción 1:2:1).
- Hendir frontal y espuma sin cortar papel posterior, cerrar alas ~45°, reforzar plegado. Comprobar estabilidad.
- **Zona baja libre:** 10 cm inferiores del panel central.
- **Izquierda:** equipo, problema, usuarios, objetivo, ilustración.
- **Centro:** título grande, cadena sensores→ADC→procesamiento/memoria→actuadores, BLE↔app, alimentación, decisión técnica.
- **Derecha:** tabla medición vs referencia/error, captura app, «¡Pruébalo tú!», dificultad y solución, futura versión.
- **Tipografía indicada:** título ≥5 cm (~140 pt), subtítulos 2–2,5 cm (~60–70 pt), texto breve 1 cm (~40 pt) cuando se imprima; máximo 3–4 líneas por bloque; 2–3 colores, fondo claro.
- El ejemplo oficial es `InvernaPIC`; su información (PIC16F877A, bomba/ventilador, HC-05) es **solo ilustrativa**: NO copiar componentes al proyecto HandSense.

## Aclaraciones importantes
- Aunque la rúbrica escriba `ADCON0/ADCON1` (registros PIC), Alex informó que el docente confirmó uso equivalente ADC del **ESP32**.
- El ejemplo y la pauta mencionan EEPROM. Si HandSense almacena umbrales persistentes, describir memoria no volátil real del ESP32-C3 y **demostrar persistencia**; no afirmar EEPROM PIC.
- No inventar resultados numéricos ni fotos.
