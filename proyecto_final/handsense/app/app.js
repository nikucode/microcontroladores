import { initialData, validateData, scenarioSteps, applyDemoStep } from './data.js';

const $ = (id) => document.getElementById(id);
const stateNames = {
  REPOSO: ['En reposo', 'Esperando flexión y contacto.'],
  FLEXION: ['Flexión detectada', 'Se observó flexión; falta confirmar contacto.'],
  CONTACTO: ['Contacto detectado', 'Se observó contacto; falta completar la liberación.'],
  LIBERACION: ['Liberación pendiente', 'El contacto terminó; falta volver a reposo.'],
  ERROR_SENAL: ['Señal no confiable', 'Se detuvo el conteo para evitar resultados incorrectos.']
};
const eventNames = {
  NINGUNO: 'Todavía no hay intentos',
  COMPLETA: 'Repetición completa',
  SIN_CONTACTO: 'Intento incompleto: falta contacto',
  SIN_FLEXION: 'Intento incompleto: falta flexión',
  SIN_LIBERACION: 'Intento incompleto: falta liberación',
  SENAL_NO_CONFIABLE: 'Conteo bloqueado: revisar señal'
};
const calibrationNames = { LISTA: 'lista', PENDIENTE: 'pendiente', INVALIDA: 'inválida' };
const settingsIds = ['large-text', 'high-contrast', 'reduced-motion', 'announce-events'];

let data = initialData();
let mode = 'demo';
let runId = 0;
let pollTimer;
let lastAnnouncement = '';

function announce(message) {
  if (!$('announce-events').checked || message === lastAnnouncement) return;
  $('announcement').textContent = message;
  lastAnnouncement = message;
}

function render() {
  const flex = Math.round(data.flexion_pct);
  const contact = Math.round(data.contacto_pct);
  $('flex-value').textContent = `${flex} %`;
  $('contact-value').textContent = `${contact} %`;
  $('flex-fill').style.width = `${flex}%`;
  $('contact-fill').style.width = `${contact}%`;
  $('flex-meter').setAttribute('aria-valuenow', String(flex));
  $('contact-meter').setAttribute('aria-valuenow', String(contact));
  $('state-label').textContent = stateNames[data.estado][0];
  $('state-description').textContent = stateNames[data.estado][1];
  $('state-label').dataset.kind = data.estado === 'ERROR_SENAL' ? 'error' : 'normal';
  $('valid-count').textContent = String(data.repeticiones);
  $('incomplete-count').textContent = String(data.incompletos);
  $('event-label').textContent = eventNames[data.ultimo_evento.codigo] ?? data.ultimo_evento.codigo.replaceAll('_', ' ');
  $('event-description').textContent = data.ultimo_evento.detalle;
  $('calibration').textContent = `Calibración: ${calibrationNames[data.calibracion]}`;
}

function setBusy(busy) {
  document.querySelectorAll('[data-scenario]').forEach((button) => { button.disabled = busy || mode !== 'demo'; });
}

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function runScenario(name) {
  if (mode !== 'demo' || !scenarioSteps[name]) return;
  const currentRun = ++runId;
  setBusy(true);
  if (data.calibracion === 'INVALIDA') data = { ...data, calibracion: 'LISTA' };
  for (const step of scenarioSteps[name]) {
    if (currentRun !== runId || mode !== 'demo') break;
    data = applyDemoStep(data, step);
    render();
    if (step.codigo) announce(`${eventNames[step.codigo]}. ${step.detalle}`);
    await delay(440);
  }
  if (currentRun === runId) setBusy(false);
}

async function readDevice() {
  const response = await fetch('/api/estado', { cache: 'no-store', signal: AbortSignal.timeout(2500) });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return validateData(await response.json());
}

async function pollDevice(currentRun) {
  if (mode !== 'device' || currentRun !== runId) return;
  try {
    const next = await readDevice();
    if (mode !== 'device' || currentRun !== runId) return;
    const eventChanged = next.ultimo_evento.codigo !== data.ultimo_evento.codigo || next.repeticiones !== data.repeticiones || next.incompletos !== data.incompletos;
    data = next;
    render();
    $('connection-description').textContent = 'ESP32 conectado. Las lecturas provienen del dispositivo.';
    if (eventChanged && next.ultimo_evento.codigo !== 'NINGUNO') announce(`${$('event-label').textContent}. ${next.ultimo_evento.detalle}`);
  } catch (error) {
    if (mode !== 'device' || currentRun !== runId) return;
    $('connection-description').textContent = 'Sin conexión con /api/estado. Abre esta página desde el ESP32 o vuelve a la demostración.';
    announce('Sin conexión con el ESP32.');
  }
  pollTimer = setTimeout(() => pollDevice(currentRun), 1000);
}

function changeMode(nextMode) {
  mode = nextMode;
  ++runId;
  clearTimeout(pollTimer);
  data = initialData();
  lastAnnouncement = '';
  render();
  setBusy(false);
  if (mode === 'device') {
    $('connection-description').textContent = 'Conectando con /api/estado…';
    pollDevice(runId);
  } else {
    $('connection-description').textContent = 'Demostración con señales simuladas. No son mediciones físicas.';
  }
}

async function sendAction(accion) {
  const response = await fetch('/api/acciones', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ accion }),
    signal: AbortSignal.timeout(2500)
  });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const reply = await response.json();
  if (reply.ok !== true) throw new Error('El ESP32 rechazó la acción.');
}

function loadSettings() {
  for (const id of settingsIds) {
    try {
      const saved = localStorage.getItem(`handsense-${id}`);
      if (saved !== null) $(id).checked = saved === 'true';
    } catch { /* El panel sigue funcionando si el almacenamiento está bloqueado. */ }
    applySetting(id);
  }
}

function applySetting(id) {
  if (id === 'large-text') document.documentElement.classList.toggle(id, $(id).checked);
  else if (id !== 'announce-events') document.body.classList.toggle(id, $(id).checked);
  try { localStorage.setItem(`handsense-${id}`, String($(id).checked)); } catch { /* Preferencia solo para esta visita. */ }
}

document.querySelectorAll('input[name="mode"]').forEach((input) => input.addEventListener('change', () => {
  if (input.checked) changeMode(input.value);
}));
document.querySelectorAll('[data-scenario]').forEach((button) => button.addEventListener('click', () => runScenario(button.dataset.scenario)));
$('reset-button').addEventListener('click', async () => {
  if (mode === 'demo') {
    ++runId;
    data = initialData();
    lastAnnouncement = '';
    render();
    setBusy(false);
    announce('Sesión reiniciada.');
    return;
  }
  try { await sendAction('reiniciar_sesion'); announce('Se solicitó reiniciar la sesión.'); }
  catch { announce('No se pudo reiniciar la sesión en el ESP32.'); $('connection-description').textContent = 'No se pudo enviar la acción al ESP32.'; }
});
$('calibrate-button').addEventListener('click', async () => {
  if (mode === 'demo') {
    data = { ...data, calibracion: 'LISTA', estado: 'REPOSO', flexion_pct: 0, contacto_pct: 0 };
    render();
    announce('Calibración simulada completada.');
    return;
  }
  try { await sendAction('calibrar'); announce('Se solicitó calibrar el dispositivo.'); }
  catch { announce('No se pudo solicitar la calibración.'); $('connection-description').textContent = 'No se pudo enviar la acción al ESP32.'; }
});
settingsIds.forEach((id) => $(id).addEventListener('change', () => applySetting(id)));
loadSettings();
render();
