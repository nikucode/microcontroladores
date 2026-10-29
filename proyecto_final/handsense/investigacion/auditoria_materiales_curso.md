# Auditoría de materiales y vacíos — Microcontroladores IAUT103

## Objetivo
Dejar identificado qué aprendizaje está realmente respaldado por trabajos/documentos, qué está solo parcialmente consolidado y qué falta practicar antes de Solemne 2 y proyecto final.

## 1. Evidencia disponible

### Trabajo Colaborativo 2 — E/S digitales
**Evidencia encontrada:** informe con:
- LED parpadeante en RB0.
- LED controlado por pulsador.
- control alternado de dos LED.
- LED controlado por dos pulsadores.
- semáforo con PIC16F877A.
- uso de MPLAB X, XC8 y SimulIDE.
- trabajo con `TRIS`, `PORT`, `ADCON1` para entradas digitales y pull-up.

**Estado:** DOCUMENTADO + FUNCIONAL EN SIMULACIÓN.

**Vacío:** todavía conviene practicar transferencia: resolver un circuito nuevo sin copiar el informe.

---

### Trabajo Colaborativo 3 — Display y LCD
**Evidencia encontrada:** guía/informe con:
- display de 7 segmentos;
- distinción ánodo común / cátodo común;
- control de segmentos;
- LCD 16x2;
- modo 4 bits;
- uso de RS, Enable y D4–D7;
- errores reales registrados: orden de segmentos y entrada RA0 flotante.

**Estado:** DOCUMENTADO + FUNCIONAL EN SIMULACIÓN.

**Vacío:** usar LCD como herramienta de depuración dinámica, no solo texto fijo.

---

### Trabajo Colaborativo 4 — ADC + LCD
**Evidencia encontrada:** documento y versión final con:
- ADC de 10 bits del PIC16F877A;
- RA0/AN0;
- `ADCON1 = 0x8E`;
- `ADCON0 = 0x41`;
- lectura de ADRESH/ADRESL;
- potenciómetro de 10 kΩ en simulación;
- conversión ADC → mV;
- LCD mostrando valor ADC y milivoltios;
- referencia conceptual al LM35.

**Estado:** DOCUMENTADO + FUNCIONAL EN SIMULACIÓN.

**Vacío crítico:** no confundir simulación con potenciómetro con validación física del LM35. Falta practicar dos canales ADC, umbrales, estados y transferencia a HandSense.

---

## 2. Contenidos del syllabus con evidencia débil o ausente

### Interrupciones
**Estado:** PENDIENTE.
No hay evidencia suficiente de una práctica consolidada de:
- ISR;
- flags;
- enable;
- interrupción RB0;
- retorno al programa principal.

### TIMER0
**Estado:** PENDIENTE.
No hay evidencia suficiente de:
- prescaler;
- cálculo de overflow;
- interrupción por desborde;
- temporización sin `__delay_ms()`.

### EEPROM
**Estado:** PENDIENTE.
No hay evidencia suficiente de:
- lectura;
- escritura;
- persistencia después de reinicio;
- almacenamiento de calibración.

### Teclado matricial
**Estado:** PENDIENTE / NO DOCUMENTADO.
Está en syllabus, pero no aparece como aprendizaje consolidado en los materiales revisados.

### USART / RS232 / MAX232 / LabVIEW
**Estado:** PENDIENTE.
Corresponde a AE4 y viene después en el calendario.

---

## 3. Hardware físico

### PICkit 3
**Estado:** COMPROBADO.
Se obtuvo `Programming/Verify complete` al programar el PIC16F877A.

### Protoboard PIC + LED (TC5 / MR1)
**Estado:** FUNCIONAL EN FÍSICO, según confirmación del usuario el 27-10-2026.
El usuario confirmó que el LED parpadea en el montaje físico y que tiene videos de evidencia. También completó el diagrama de Fritzing con un terminal de dos pines para representar la fuente de 5 V, cable rojo a positivo, cable azul a GND y puentes de rieles.

**Límite documental:** ni los videos ni el archivo `.fzz` estaban adjuntos como archivos accesibles al generar esta versión del ZIP; se incorpora un registro escrito de lo confirmado. Fritzing no realiza simulación eléctrica.

### Decisión
No repetir la depuración de MR1 desde cero si el montaje continúa funcionando. Comprobar los conceptos (VDD/VSS, MCLR, reloj, RB0, `TRISB` y `PORTB`) y pasar al siguiente mini-reto cuando corresponda.
Para circuitos nuevos, mantener la secuencia: entender → simular → verificar → modificar → explicar → replicar físicamente → medir → documentar.

---

## 4. Mapa de dominio real

| Competencia | Evidencia | Estado |
|---|---|---|
| C básico | trabajos previos | funcional/parcial |
| TRIS / PORT | TC2 | funcional |
| LED / botón | TC2 | funcional en simulación |
| pull-up | TC2 | funcional |
| display 7 segmentos | TC3 | funcional |
| LCD 16x2 | TC3 | funcional |
| ADC 1 canal | TC4 | funcional en simulación |
| ADC 2 canales | no encontrada | pendiente |
| interrupciones | no encontrada | pendiente |
| TIMER0 | no encontrada | pendiente |
| EEPROM | no encontrada | pendiente |
| teclado matricial | no encontrada | pendiente |
| USART | no encontrada | pendiente |
| LabVIEW | no encontrada | pendiente |
| montaje físico PIC + LED | confirmación del usuario + videos en su dispositivo | funcional en físico; archivos de evidencia no incluidos en este ZIP |
| HandSense modular | planificación | planificado |

---

## 5. Prioridad de aprendizaje

### Prioridad máxima
1. interrupciones;
2. TIMER0;
3. ADC profundo / dos canales;
4. EEPROM.

### Prioridad alta
5. botón + LED y transferencia a circuitos nuevos (MR2);
6. integración ADC + estados + timer;
7. HandSense simulado mínimo.

### Prioridad media
8. teclado matricial;
9. LCD como depuración;
10. repaso display.

### Posterior
11. USART;
12. LabVIEW;
13. dashboard / comunicación final.

---

## 6. Qué conviene hacer todavía con Plus

### Sí vale la pena
- crear una guía técnica profunda de interrupciones + TIMER0 adaptada al PIC16F877A;
- diseñar ejercicios progresivos con soluciones y errores típicos;
- preparar una guía de EEPROM + calibración aplicada a HandSense;
- dejar una matriz syllabus → evidencia → evaluación → mini-reto;
- preparar prompts/handoff para continuar en Free sin reconstruir contexto.

### Puede esperar a Free
- cablear cada componente en SimulIDE;
- revisar capturas una por una;
- corregir conexiones de protoboard;
- cambiar delays, pines o umbrales;
- ejecutar mini-retos repetitivos;
- depuración incremental de código.

---

## 7. Siguiente bloque recomendado
**Interrupciones + TIMER0 desde cero, con modelo mental, registros, flujo de ejecución, cálculo de tiempos y un mini-reto en SimulIDE.**

Criterio de cierre:
- explicar polling vs interrupción;
- reconocer flag/enable;
- entender ISR;
- explicar overflow;
- usar prescaler;
- hacer parpadear un LED con TIMER0 sin depender de `__delay_ms()`.
