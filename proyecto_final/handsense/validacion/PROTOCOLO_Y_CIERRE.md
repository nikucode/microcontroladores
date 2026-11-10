# Protocolo y matriz de cierre — 10 de noviembre de 2026

Este protocolo se fija antes de medir hardware. Los criterios son objetivos de ingeniería propuestos; no equivalen a certificación clínica.

| Requisito | Evidencia actual | Prueba para cerrar | Estado |
|---|---|---|---|
| Dos ADC | Potenciómetros Wokwi | Cada sensor real cambia independientemente; registrar reposo y gesto | Simulado |
| Conteo | Cinco pruebas C++ | Secuencias observadas manualmente y comparación en las mismas señales | Parcial |
| LED y motor | LED simulado | Activación física, corriente y ausencia de reinicios; percepción del pulso | Pendiente |
| Memoria | Propuesta | Guardar calibración válida, apagar y recuperar mismos parámetros | Pendiente |
| Wi-Fi/app | Demo y contrato | Datos reales, reconexión y acciones verificadas | Pendiente |
| Soporte | Propuesta | Tiempo de colocación, interferencia con pinza y recolocación registrados | Pendiente |

## Brechas del código que condicionan la integración

- `gesture_logic.h` emite ESPERA_REPOSO; `app/data.js` solo admite REPOSO, FLEXION, CONTACTO, LIBERACION y ERROR_SENAL. Definir y probar una representación explícita antes de transmitir JSON.
- ERROR_SENAL y calibración inválida son escenarios de la app; el detector no implementa ese bloqueo todavía.
- La regla actual recuerda haber visto flexión y contacto. Debe documentarse qué orden/solapamiento se acepta y probar contacto primero, flexión primero y entradas simultáneas.
- Los 3 segundos y umbrales del sketch son provisionales. No utilizarlos como tiempo terapéutico ni umbral universal.

## Calibración propuesta

1. Fotografiar circuito y registrar placa, resistencias, montaje, versión y fuente.
2. Registrar diez segundos de reposo y cinco gestos cómodos de desarrollo, sin exigir fuerza máxima. Guardar ambas señales crudas con tiempo.
3. Determinar polaridad, rango, variación y saturación. Si reposo y gesto no se separan, revisar montaje antes de elegir umbrales.
4. Normalizar cada canal con sus referencias medidas; comprobar denominador no nulo y rango útil. Elegir histéresis con los registros de desarrollo y documentar los valores.
5. Guardar únicamente parámetros confirmados; verificar recuperación tras apagar. Rechazar calibración inválida y bloquear conteo.
6. Recolocar tres veces; registrar cambio de línea base y si requiere recalibrar. No asumir que un extremo ADC demuestra desconexión: un FSR descargado puede producir ese extremo legítimamente.

## Evaluación funcional propuesta

Usar ensayos nuevos después de fijar parámetros. Como piloto de ingeniería, intentar diez ensayos por clase: pinza completa, solo flexión, solo contacto, contacto sostenido. Registrar también reposo y dos pinzas consecutivas. Si se obtienen menos, informar el número real. Estos ensayos repetidos no son diez personas independientes.

Ejecutar detector por flexión y por fusión sobre las mismas señales. Etiqueta manual independiente: ¿hubo flexión, contacto y retorno observados? Registrar desacuerdos; no usar el propio algoritmo como verdad de referencia. Informar TP, FP, FN, TN con denominadores, tasa de abstención y fallos por clase. No ajustar parámetros usando la evaluación; si se ajustan, repetir con datos nuevos.

Comprobar motor activado mientras se adquiere ADC, reinicio, pérdida/reconexión Wi-Fi, órdenes de reinicio de sesión y datos inválidos. Registrar por separado integración y calidad del conteo.

## Formato de datos

`ensayos.csv` es una plantilla vacía. Cada fila resume un intento; los registros crudos se guardan aparte con columnas tiempo_ms, adc_flex, adc_fsr. Vincularlos mediante archivo_registro. No publicar nombres, videos identificables ni información de salud sin consentimiento.

## Entrevistas exploratorias futuras

Hipótesis de usuario: persona que puede practicar una pinza voluntaria y desea comprender sus repeticiones; el perfil debe discutirse con profesionales y usuarios. Comprador posible: centro o usuario; pagador aún desconocido.

Preguntar: ¿cómo practica hoy?, ¿qué le cuesta preparar?, ¿qué mensaje entiende?, ¿qué incomoda?, ¿qué alternativa usa?, ¿qué costo de compra y mantenimiento sería asumible? Pedir permiso antes de registrar respuestas y permitir retirarse. No solicitar ejercicios dolorosos ni prometer beneficio terapéutico.

Medir tiempo de colocación, ayuda necesaria, errores de interpretación y percepción del pulso. Para aliados/inversores mostrar resultados reales, costo completo, reparación y próximos experimentos; la disposición a pagar y la utilidad son hipótesis pendientes.
