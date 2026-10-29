# Auditoría técnica HandSense — v1
**Asignatura:** Microcontroladores IAUT103<br>
**Proyecto:** HandSense — sistema experimental de monitoreo de ejercicios simples de mano<br>
**Objetivo de esta auditoría:** reducir decisiones abiertas antes de comprar, montar e integrar hardware.

---

## 1. Requisitos del proyecto ya definidos

### Entradas
- Sensor resistivo de flexión.
- Sensor FSR para presión.
- Pulsador opcional de calibración.

### Salidas
- LED de retroalimentación visual.
- Motor vibrador para retroalimentación háptica.

### Procesamiento / comunicación
- ESP32 propuesto como controlador.
- Comunicación inalámbrica WiFi/BLE.
- Dashboard/App para visualizar:
  - flexión;
  - presión;
  - repeticiones;
  - estado del ejercicio.

### Restricción académica importante
El syllabus del curso trabaja con PIC16F877A, ADC, EEPROM, interrupciones, timers y posteriormente USART/LabVIEW.<br>
**PENDIENTE DE VALIDACIÓN:** confirmar con el profesor si el proyecto final puede ser:
1. ESP32 solamente;
2. PIC16F877A + ESP32;
3. otra arquitectura aceptada.

No comprar controlador definitivo hasta cerrar esta pregunta si el proyecto aún no ha sido aprobado explícitamente con ESP32.

---

# 2. Arquitectura recomendada por módulos

```text
Flex sensor ── divisor resistivo ── ADC1 ──┐
                                           │
FSR ───────── divisor resistivo ── ADC1 ───┤
                                           ↓
                                    procesamiento
                                           │
                  ┌────────────────────────┼────────────────────────┐
                  ↓                        ↓                        ↓
             LED estado             driver motor             calibración
                                        ↓                         ↓
                                  motor vibrador            memoria NVS
                                           │
                                           ↓
                                      WiFi / BLE
                                           │
                                           ↓
                                       dashboard
```

---

# 3. Decisión crítica sobre entradas ADC

## Si se usa ESP32 clásico
Reservar los sensores analógicos preferentemente en **ADC1**.

Motivo:
- en el ESP32 clásico, ADC2 comparte recursos con WiFi;
- una lectura ADC2 puede fallar mientras WiFi está activo;
- ADC1 evita esa dependencia para los dos sensores principales.

### Regla de diseño
No asignar pines concretos hasta conocer el modelo exacto de placa.

**Estado:** DECISIÓN TÉCNICA RECOMENDADA, pendiente de modelo exacto.

---

# 4. Módulo flex sensor

## Qué es
Un flex sensor funciona como una resistencia variable:
- poca flexión → una resistencia;
- mayor flexión → aumenta su resistencia.

## Cómo leerlo
No se mide la resistencia directamente con el ADC.

Se forma un divisor resistivo:

```text
3.3 V
  │
flex sensor
  │
  ├──── ADC
  │
resistencia fija
  │
 GND
```

La posición relativa de sensor/resistencia puede invertirse según qué dirección de cambio se quiera obtener.

## Qué NO fijar todavía
- valor de la resistencia fija;
- ecuación de conversión a grados;
- umbrales finales.

Esos valores dependen del modelo físico del flex sensor y de la mecánica del soporte.

## Criterios de prueba
1. lectura estable en reposo;
2. lectura cambia de forma repetible al doblar;
3. rango útil suficientemente amplio;
4. no exceder el rango admisible del ADC;
5. calibrar MIN/MAX por usuario o montaje.

**Estado:** ARQUITECTURA DEFINIDA / COMPONENTE EXACTO PENDIENTE.

---

# 5. Módulo FSR

## Qué es
Un FSR reduce su resistencia cuando aumenta la fuerza aplicada.

## Lectura recomendada
También usar divisor resistivo:

```text
3.3 V
  │
 FSR
  │
  ├──── ADC
  │
resistencia fija
  │
 GND
```

## Objetivo realista
Usarlo primero como **medición relativa de presión/fuerza**, no como instrumento clínico de fuerza absoluta.

Ejemplo:
- baja;
- media;
- alta;
- excesiva respecto de una referencia experimental.

## No afirmar todavía
- newtons exactos;
- presión clínica;
- rango terapéutico correcto.

Eso requiere calibración mecánica y validación adicional.

**Estado:** ARQUITECTURA DEFINIDA / MODELO EXACTO PENDIENTE.

---

# 6. LED

Circuito básico:

```text
GPIO ── resistencia limitadora ── LED ── GND
```

Uso propuesto:
- apagado: reposo;
- encendido: repetición válida;
- parpadeo: advertencia / calibración.

Puede reutilizar aprendizajes de salida digital.

**Estado:** SIMPLE / BAJO RIESGO.

---

# 7. Motor vibrador

## No conectar directamente a GPIO

Arquitectura:

```text
GPIO
 │
resistencia de control
 │
transistor / MOSFET
 │
motor vibrador
 │
alimentación
```

Según el tipo de motor y driver puede requerirse protección contra transitorios.

## Antes de dimensionar
Necesitamos conocer:
- tensión nominal del motor;
- corriente de funcionamiento;
- corriente de arranque;
- tipo exacto de motor.

## Primera simulación
Sustituir el motor por un segundo LED.

## Segunda prueba
Motor real + etapa de potencia en mesa.

**Estado:** PLANIFICADO / DRIVER NO DIMENSIONADO.

---

# 8. Calibración y memoria

Guardar valores pequeños:
- flex_min;
- flex_max;
- presión_referencia;
- umbral_alto;
- umbral_bajo.

Si se usa ESP32, NVS es apropiado para pequeños pares clave-valor persistentes.

### Flujo recomendado
```text
usuario presiona CALIBRAR
        ↓
leer sensores
        ↓
guardar referencias
        ↓
reiniciar
        ↓
recuperar valores
```

No escribir continuamente en memoria durante cada muestra.

**Estado:** DISEÑO FUNCIONAL DEFINIDO / IMPLEMENTACIÓN PENDIENTE.

---

# 9. Detección de repetición

No hacer:

```c
if (flexion > umbral)
    repeticiones++;
```

Porque contaría varias veces mientras el dedo siga flexionado.

Usar máquina de estados + histéresis:

```c
if (estado == RELAJADO && flexion > umbral_alto) {
    repeticiones++;
    estado = FLEXIONADO;
}

if (estado == FLEXIONADO && flexion < umbral_bajo) {
    estado = RELAJADO;
}
```

Esto será uno de los núcleos de aprendizaje del proyecto.

**Estado:** ALGORITMO BASE DEFINIDO.

---

# 10. Uso de TIMER / tiempo

Posibles usos:
- tiempo de una repetición;
- duración del ejercicio;
- muestreo periódico;
- debounce sin bloquear;
- tiempo mínimo antes de aceptar otra repetición.

### Diseño recomendado
Evitar que toda la lógica dependa de `delay()` o `__delay_ms()`.

**Estado:** PLANIFICADO; se aprenderá primero con TIMER0 en PIC.

---

# 11. Comunicación y dashboard

## Versión mínima
Enviar:
- flexión;
- presión;
- contador de repeticiones;
- estado.

Dashboard mínimo:

```text
HandSense

Flexión:       63 %
Presión:       41 %
Repeticiones:   8
Estado:        ACTIVO
```

## Versión posterior
- gráficos en el tiempo;
- botón reset;
- calibración;
- historial de sesión.

No diseñar una aplicación grande antes de validar sensores y lógica.

**Estado:** PLANIFICADO.

---

# 12. Tres niveles del proyecto

## A — Simulación mínima
- POT1 = flex.
- POT2 = FSR.
- LED1 = feedback visual.
- LED2 = motor simulado.
- lógica de estados y repeticiones.

### Cierre
✓ dos ADC independientes<br>
✓ umbrales<br>
✓ estados<br>
✓ una repetición se cuenta una sola vez<br>
✓ advertencia por presión

---

## B — Prototipo de mesa
- sensor flex real;
- FSR real;
- LED;
- motor + driver;
- controlador;
- monitor serie.

### Cierre
✓ sensores repetibles<br>
✓ motor seguro<br>
✓ calibración funcional<br>
✓ lógica estable

---

## C — Prototipo final
- soporte/guante;
- calibración persistente;
- comunicación inalámbrica;
- dashboard;
- validación integrada.

### Cierre
✓ todos los módulos funcionan juntos<br>
✓ resultados demostrables<br>
✓ documentación de límites y alcance

---

# 13. Lista de componentes — estado

## Ya podemos considerar necesarios
- 1 flex sensor.
- 1 FSR.
- 1 controlador aprobado por profesor.
- 1 LED + resistencia.
- 1 pulsador.
- 1 motor vibrador.
- 1 transistor/MOSFET o driver adecuado.
- resistencias para divisores.
- protoboard.
- jumpers.
- fuente/USB según arquitectura.

## NO fijar todavía
- modelo exacto de ESP32;
- valores exactos de divisores;
- MOSFET/transistor específico;
- batería;
- regulador;
- PCB;
- guante definitivo;
- carcasa.

---

# 14. Preguntas concretas para el profesor

1. ¿Está aprobado usar ESP32 como controlador principal en el proyecto final?
2. ¿Se espera integrar explícitamente PIC16F877A en el proyecto?
3. ¿La comunicación inalámbrica del enunciado reemplaza o complementa USART/LabVIEW?
4. ¿Los dos actuadores pueden ser un LED y un motor vibrador?
5. ¿Se evaluará medición absoluta de los sensores o basta una medición calibrada/relativa?
6. ¿Hay componentes específicos disponibles en laboratorio para flexión, FSR y vibración?
7. ¿Qué evidencia espera en la presentación final: montaje, dashboard, mediciones, informe, demostración en vivo?

Cerrar estas preguntas antes de compras definitivas.

---

# 15. Reparto de trabajo sugerido Alex / Cote

El proyecto debe seguir siendo comprensible para ambos; la división es por responsabilidad primaria, no por conocimiento exclusivo.

## Rama A
- sensado flex;
- lectura ADC;
- calibración;
- algoritmo de repetición.

## Rama B
- FSR;
- feedback LED/motor;
- etapa de potencia;
- pruebas de actuador.

## Compartido
- arquitectura;
- integración;
- comunicación/dashboard;
- pruebas;
- documentación;
- presentación.

### Regla
Cada módulo desarrollado por una persona debe ser explicado y revisado por la otra antes de marcarlo `INTEGRABLE`.

---

# 16. Matriz de validación

| Módulo | Simulado | Mesa | Integrado |
|---|---|---|---|
| Flex / POT1 | pendiente | pendiente | pendiente |
| FSR / POT2 | pendiente | pendiente | pendiente |
| LED | pendiente | pendiente | pendiente |
| Motor simulado | pendiente | — | pendiente |
| Motor real | — | pendiente | pendiente |
| Estados/repeticiones | pendiente | pendiente | pendiente |
| Calibración | pendiente | pendiente | pendiente |
| Memoria | pendiente | pendiente | pendiente |
| Comunicación | pendiente | pendiente | pendiente |
| Dashboard | pendiente | pendiente | pendiente |

---

# 17. Orden de implementación recomendado

1. POT1 → ADC → monitor/LCD.
2. POT2 → ADC → monitor/LCD.
3. dos ADC simultáneos.
4. umbrales.
5. estados e histéresis.
6. contador de repeticiones.
7. LED.
8. calibración.
9. memoria.
10. segundo LED simulando motor.
11. flex sensor real.
12. FSR real.
13. motor real + driver.
14. comunicación.
15. dashboard.
16. soporte/guante.
17. integración final.

---

# 18. Criterio de alcance

Presentar HandSense como:
**“sistema experimental de monitoreo de ejercicios simples de mano”**

No presentarlo como:
- dispositivo médico validado;
- sistema clínico;
- instrumento de medición terapéutica exacta.

Mientras no exista validación clínica/metrológica, los valores deben interpretarse como mediciones experimentales/calibradas del prototipo.

---

# 19. NEXT_ACTION

Antes de comprar componentes:
1. confirmar arquitectura con profesor;
2. identificar modelo de placa disponible;
3. identificar flex sensor / FSR disponibles en laboratorio;
4. completar MVP con potenciómetros.

Después de eso se puede generar una BOM exacta con valores y conexiones.
