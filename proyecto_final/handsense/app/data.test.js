import test from 'node:test';
import assert from 'node:assert/strict';
import { initialData, validateData, scenarioSteps, applyDemoStep, readingStatus } from './data.js';

test('la demostración distingue una pinza completa de intentos incompletos', () => {
  let data = initialData();
  for (const step of scenarioSteps.complete) data = applyDemoStep(data, step);
  assert.equal(data.repeticiones, 1);
  assert.equal(data.incompletos, 0);
  assert.equal(data.ultimo_evento.codigo, 'COMPLETA');

  for (const name of ['flex', 'contact', 'hold']) {
    for (const step of scenarioSteps[name]) data = applyDemoStep(data, step);
  }
  assert.equal(data.repeticiones, 1);
  assert.equal(data.incompletos, 3);
  assert.equal(data.ultimo_evento.codigo, 'SIN_LIBERACION');
});

test('la señal no confiable bloquea el conteo de la demostración', () => {
  const data = applyDemoStep(initialData(), scenarioSteps.error[0]);
  assert.equal(data.estado, 'ERROR_SENAL');
  assert.equal(data.calibracion, 'INVALIDA');
  assert.equal(data.repeticiones, 0);
});

test('se rechazan datos incompatibles o fuera de rango del ESP32', () => {
  const valid = initialData();
  assert.equal(validateData(valid), valid);
  assert.throws(() => validateData({ ...valid, schema: 2 }), /Versión/);
  assert.throws(() => validateData({ ...valid, flexion_pct: 101 }), /flexion_pct/);
  assert.throws(() => validateData({ ...valid, estado: 'DESCONOCIDO' }), /Estado/);
  assert.throws(() => validateData({ ...valid, repeticiones: -1 }), /Conteo/);
});

test('el estado de espera del firmware es compatible con la app', () => {
  assert.equal(validateData({ ...initialData(), estado: 'ESPERA_REPOSO' }).estado, 'ESPERA_REPOSO');
});
test('la conexión y calibración condicionan la interpretación sin alterar contadores', () => {
  const data = { ...initialData(), repeticiones: 8 };
  assert.equal(readingStatus(data, 'device', false).usable, false);
  assert.equal(readingStatus(data, 'device', true).usable, true);
  for (const calibracion of ['INVALIDA', 'PENDIENTE']) assert.equal(readingStatus({ ...data, calibracion }, 'device', true).usable, false);
  assert.equal(readingStatus({ ...data, estado: 'ERROR_SENAL' }, 'demo', false).usable, false);
  assert.equal(readingStatus(data, 'demo', false).title, 'Ejemplo simulado');
  assert.equal(data.repeticiones, 8);
});
