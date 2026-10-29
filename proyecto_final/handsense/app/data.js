export const initialData = () => ({
  schema: 1,
  timestamp_ms: Date.now(),
  flexion_pct: 0,
  contacto_pct: 0,
  estado: 'REPOSO',
  calibracion: 'LISTA',
  repeticiones: 0,
  incompletos: 0,
  ultimo_evento: { codigo: 'NINGUNO', detalle: 'Elige una prueba para ver cómo responde el panel.' }
});

export function validateData(value) {
  if (!value || typeof value !== 'object' || value.schema !== 1) throw new Error('Versión de datos no compatible.');
  for (const key of ['flexion_pct', 'contacto_pct']) {
    if (typeof value[key] !== 'number' || !Number.isFinite(value[key]) || value[key] < 0 || value[key] > 100) throw new Error(`Valor inválido: ${key}.`);
  }
  for (const key of ['repeticiones', 'incompletos']) {
    if (!Number.isSafeInteger(value[key]) || value[key] < 0) throw new Error(`Conteo inválido: ${key}.`);
  }
  if (!['REPOSO', 'FLEXION', 'CONTACTO', 'LIBERACION', 'ERROR_SENAL'].includes(value.estado)) throw new Error('Estado desconocido.');
  if (!['LISTA', 'PENDIENTE', 'INVALIDA'].includes(value.calibracion)) throw new Error('Calibración desconocida.');
  if (!value.ultimo_evento || typeof value.ultimo_evento !== 'object' || typeof value.ultimo_evento.codigo !== 'string' || typeof value.ultimo_evento.detalle !== 'string') throw new Error('Último evento inválido.');
  return value;
}

export const scenarioSteps = {
  complete: [
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO' },
    { flexion_pct: 67, contacto_pct: 0, estado: 'FLEXION' },
    { flexion_pct: 76, contacto_pct: 72, estado: 'CONTACTO' },
    { flexion_pct: 54, contacto_pct: 0, estado: 'LIBERACION' },
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO', repeticionesDelta: 1, codigo: 'COMPLETA', detalle: 'Flexión y contacto detectados; después hubo liberación y retorno a reposo.' }
  ],
  flex: [
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO' },
    { flexion_pct: 72, contacto_pct: 0, estado: 'FLEXION' },
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO', incompletosDelta: 1, codigo: 'SIN_CONTACTO', detalle: 'Se detectó flexión, pero no hubo contacto de pinza.' }
  ],
  contact: [
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO' },
    { flexion_pct: 9, contacto_pct: 77, estado: 'CONTACTO' },
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO', incompletosDelta: 1, codigo: 'SIN_FLEXION', detalle: 'Hubo contacto, pero la flexión del índice fue insuficiente.' }
  ],
  hold: [
    { flexion_pct: 0, contacto_pct: 0, estado: 'REPOSO' },
    { flexion_pct: 70, contacto_pct: 0, estado: 'FLEXION' },
    { flexion_pct: 75, contacto_pct: 78, estado: 'CONTACTO' },
    { flexion_pct: 75, contacto_pct: 78, estado: 'CONTACTO', incompletosDelta: 1, codigo: 'SIN_LIBERACION', detalle: 'El contacto se mantuvo; no se observó la liberación necesaria para contar la repetición.' }
  ],
  error: [
    { flexion_pct: 0, contacto_pct: 0, estado: 'ERROR_SENAL', calibracion: 'INVALIDA', codigo: 'SENAL_NO_CONFIABLE', detalle: 'La señal no es confiable. El conteo queda bloqueado hasta revisar la entrada y calibrar.' }
  ]
};

export function applyDemoStep(data, step) {
  return validateData({
    ...data,
    timestamp_ms: Date.now(),
    flexion_pct: step.flexion_pct,
    contacto_pct: step.contacto_pct,
    estado: step.estado,
    calibracion: step.calibracion ?? data.calibracion,
    repeticiones: data.repeticiones + (step.repeticionesDelta ?? 0),
    incompletos: data.incompletos + (step.incompletosDelta ?? 0),
    ultimo_evento: step.codigo ? { codigo: step.codigo, detalle: step.detalle } : data.ultimo_evento
  });
}
