import 'package:flutter/material.dart';

import '../data/attempt.dart';
import 'handsense_logo.dart';
import 'session_model.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: EdgeInsets.all(constraints.maxWidth < 360 ? 16 : 24),
      children: [
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
      ],
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );
}

class HandIllustration extends StatelessWidget {
  const HandIllustration({
    super.key,
    required this.asset,
    required this.semanticLabel,
    this.height = 220,
  });
  final String asset;
  final String semanticLabel;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: semanticLabel,
    child: ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    ),
  );
}

Widget heading(BuildContext context, String text) =>
    Text(text, style: Theme.of(context).textTheme.headlineMedium);

class SourceNotice extends StatelessWidget {
  const SourceNotice({super.key, required this.model});
  final SessionModel model;
  @override
  Widget build(BuildContext context) => Text(
    model.isDemo
        ? 'Demostración · Datos simulados. Sin conexión con sensores físicos.'
        : model.isConnected
        ? 'Dispositivo real · Los eventos provienen del ESP32 conectado.'
        : 'Dispositivo real seleccionado · Aún no hay conexión ni mediciones.',
  );
}

class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({super.key, required this.model});
  final SessionModel model;

  @override
  Widget build(BuildContext context) {
    final telemetry = model.telemetry;
    final age = model.telemetryAge;
    if (model.isDemo) return const SizedBox.shrink();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Señales en tiempo real',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (!model.isConnected || telemetry == null)
            const Text('Sin datos del ESP32: —')
          else ...[
            Semantics(
              liveRegion: true,
              child: Text(
                'Estado: ${telemetry.phaseLabel}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              model.telemetryFresh
                  ? 'Actualización recibida hace ${age?.inSeconds ?? 0} s'
                  : 'Datos antiguos: hace ${age?.inSeconds ?? 0} s. El conteo está bloqueado.',
            ),
            const SizedBox(height: 8),
            if (telemetry.phase == GesturePhase.signalError)
              const Text(
                'Señal no evaluable. El firmware no identifica qué sensor originó este estado; el conteo está bloqueado.',
              )
            else ...[
              Text('Flexión relativa: ${telemetry.flexionPercent} %'),
              LinearProgressIndicator(value: telemetry.flexionPercent / 100),
              const SizedBox(height: 8),
              Text('Contacto relativo: ${telemetry.contactPercent} %'),
              LinearProgressIndicator(value: telemetry.contactPercent / 100),
              const SizedBox(height: 8),
              const Text(
                'Porcentajes relativos entregados por el firmware; no son grados, newtons ni una confirmación individual del sensor.',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onAbout,
    required this.onAccessibility,
  });
  final VoidCallback onStart;
  final VoidCallback onAbout;
  final VoidCallback onAccessibility;

  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      const SizedBox(height: 16),
      const Center(child: HandSenseLogo()),
      Center(
        child: Text(
          'HandSense',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      Center(
        child: Text(
          'Movimiento con sentido',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const Text(
        'Herramienta de práctica y registro de movimientos de pinza.',
        textAlign: TextAlign.center,
      ),
      FilledButton(
        key: const ValueKey('welcome-start'),
        onPressed: onStart,
        child: const Text('Comenzar'),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TextButton(
              key: const ValueKey('welcome-about'),
              onPressed: onAbout,
              child: const Text('Sobre HandSense'),
            ),
          ),
          Flexible(
            child: TextButton.icon(
              key: const ValueKey('welcome-accessibility'),
              onPressed: onAccessibility,
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Accesibilidad'),
            ),
          ),
        ],
      ),
      Text(
        'Prototipo universitario experimental · Sin validación clínica',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.model,
    required this.onExercise,
    required this.onGuide,
    required this.onUseDevice,
    required this.onUseDemo,
  });
  final SessionModel model;
  final VoidCallback onExercise;
  final VoidCallback onGuide;
  final VoidCallback onUseDevice;
  final VoidCallback onUseDemo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDemoActivity = false;

  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'Movimiento con sentido'),
      const Text('Practica la secuencia de pinza y comprende cada resultado.'),
      FilledButton.icon(
        key: const ValueKey('start-demo'),
        onPressed: widget.onExercise,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Preparar práctica'),
      ),
      OutlinedButton.icon(
        key: const ValueKey('open-guide'),
        onPressed: widget.onGuide,
        icon: const Icon(Icons.menu_book_outlined),
        label: const Text('Ver guía visual'),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              widget.model.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth,
              semanticLabel: widget.model.isConnected
                  ? 'Dispositivo conectado'
                  : 'Dispositivo sin conectar',
            ),
            const SizedBox(height: 8),
            Text(
              widget.model.isDemo
                  ? 'Origen: demostración'
                  : 'Dispositivo: ${widget.model.connectionState.deviceName ?? 'HandSense'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.model.isConnected
                  ? 'Conectado'
                  : widget.model.isDemo
                  ? 'Datos simulados'
                  : 'Sin conexión',
            ),
            const SizedBox(height: 12),
            if (widget.model.isDemo)
              TextButton.icon(
                key: const ValueKey('connect-device'),
                onPressed: widget.onUseDevice,
                icon: const Icon(Icons.bluetooth_searching),
                label: const Text('Conectar equipo'),
              )
            else
              TextButton(
                key: const ValueKey('use-demo'),
                onPressed: widget.onUseDemo,
                child: const Text('Usar demostración'),
              ),
          ],
        ),
      ),
      ActivityDashboard(
        sessions: widget.model.sessions,
        showDemo: showDemoActivity,
        onModeChanged: (demo) => setState(() => showDemoActivity = demo),
      ),
    ],
  );
}

class ActivityDashboard extends StatelessWidget {
  const ActivityDashboard({
    super.key,
    required this.sessions,
    required this.showDemo,
    required this.onModeChanged,
  });

  final List<SessionRecord> sessions;
  final bool showDemo;
  final ValueChanged<bool> onModeChanged;

  static final SessionRecord _demoExample = SessionRecord(
    0,
    DateTime(2026, 11, 27),
    'Ejemplo simulado',
    true,
    const [
      Attempt(1, Outcome.complete),
      Attempt(2, Outcome.noContact),
      Attempt(3, Outcome.noFlexion),
      Attempt(4, Outcome.noRelease),
      Attempt(5, Outcome.unreliable),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final hasDemoSessions = sessions.any((session) => session.isDemo);
    final usingDemoExample = showDemo && !hasDemoSessions;
    final displayedSessions = usingDemoExample
        ? [...sessions, _demoExample]
        : sessions;
    final summary = ActivitySummary.fromSessions(
      displayedSessions,
      demo: showDemo,
    );
    final percentage = summary.completionPercentage;
    final latest = summary.latest;
    return Column(
      key: const ValueKey('activity-dashboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividad', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('activity-real'),
              label: const Text('Actividad real'),
              selected: !showDemo,
              onSelected: (_) => onModeChanged(false),
            ),
            ChoiceChip(
              key: const ValueKey('activity-demo'),
              label: const Text('Demostración'),
              selected: showDemo,
              onSelected: (_) => onModeChanged(true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (usingDemoExample)
          const Panel(
            child: Text(
              'Ejemplo simulado · no guardado. Se muestran los cinco '
              'resultados de demostración disponibles.',
            ),
          )
        else if (summary.sessions.isEmpty)
          Panel(
            child: Text(
              showDemo
                  ? 'Aún no hay sesiones de demostración registradas.'
                  : 'Aún no hay sesiones reales registradas.',
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final singleColumn =
                constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(1) >= 1.5;
            final width = singleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActivityMetric(
                  key: const ValueKey('dashboard-total'),
                  width: width,
                  label: 'Intentos totales',
                  value: '${summary.totalAttempts}',
                ),
                _ActivityMetric(
                  key: const ValueKey('dashboard-complete'),
                  width: width,
                  label: 'Pinzas completas',
                  value: '${summary.complete}',
                ),
                _ActivityMetric(
                  key: const ValueKey('dashboard-incomplete'),
                  width: width,
                  label: 'Intentos incompletos',
                  value: '${summary.incomplete}',
                ),
                _ActivityMetric(
                  key: const ValueKey('dashboard-unreliable'),
                  width: width,
                  label: 'Intentos sin lectura fiable',
                  value: '${summary.unreliable}',
                ),
                _ActivityMetric(
                  key: const ValueKey('dashboard-evaluable'),
                  width: width,
                  label: 'Intentos evaluables',
                  value: '${summary.evaluable}',
                ),
                _ActivityMetric(
                  key: const ValueKey('dashboard-percentage'),
                  width: width,
                  label: 'Porcentaje de pinzas completas',
                  value: percentage == null ? '—' : '${percentage.round()} %',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Última sesión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                latest == null
                    ? 'Sin datos disponibles.'
                    : '${latest.source} · ${latest.attempts.length} registros\n'
                          '${latest.complete} completas · ${latest.incomplete} incompletas · '
                          '${latest.unreliable} no evaluables',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Panel(child: _OutcomeBarChart(summary: summary)),
        const SizedBox(height: 12),
        Panel(child: _EvolutionChart(sessions: summary.recentSessions)),
      ],
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    super.key,
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _OutcomeBarChart extends StatelessWidget {
  const _OutcomeBarChart({required this.summary});
  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    final values = <(String, int, Color)>[
      ('Completos', summary.complete, Theme.of(context).colorScheme.primary),
      (
        'Incompletos',
        summary.incomplete,
        Theme.of(context).colorScheme.tertiary,
      ),
      (
        'No evaluables',
        summary.unreliable,
        Theme.of(context).colorScheme.error,
      ),
    ];
    final maximum = values.fold<int>(
      1,
      (max, item) => item.$2 > max ? item.$2 : max,
    );
    return Column(
      key: const ValueKey('outcome-bar-chart'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultados por tipo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Cantidad de intentos'),
        const SizedBox(height: 12),
        for (final item in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              label: '${item.$1}: ${item.$2} intentos',
              child: Row(
                children: [
                  SizedBox(width: 104, child: Text(item.$1)),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            if (item.$2 > 0)
                              Container(
                                width: constraints.maxWidth * item.$2 / maximum,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: item.$3,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('${item.$2}', textAlign: TextAlign.end),
                  ),
                ],
              ),
            ),
          ),
        if (summary.totalAttempts == 0)
          const Center(child: Text('Sin registros todavía.')),
      ],
    );
  }
}

class _EvolutionChart extends StatelessWidget {
  const _EvolutionChart({required this.sessions});
  final List<SessionRecord> sessions;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('evolution-chart'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Evolución de pinzas completas',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text('Porcentaje por sesión · últimas 7 · escala 0–100 %'),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 116),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: sessions.isEmpty
            ? const Center(child: Text('Sin sesiones para mostrar.'))
            : Column(
                children: [
                  for (var index = 0; index < sessions.length; index++)
                    _EvolutionRow(index: index, session: sessions[index]),
                ],
              ),
      ),
      const SizedBox(height: 4),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('0 %'), Text('100 %')],
      ),
    ],
  );
}

class _EvolutionRow extends StatelessWidget {
  const _EvolutionRow({required this.index, required this.session});
  final int index;
  final SessionRecord session;

  @override
  Widget build(BuildContext context) {
    final evaluable = session.complete + session.incomplete;
    final percentage = evaluable == 0
        ? null
        : session.complete * 100 / evaluable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        label:
            'Sesión ${index + 1}: ${percentage == null ? 'porcentaje indefinido' : '${percentage.round()} por ciento'}',
        child: Row(
          children: [
            SizedBox(width: 30, child: Text('S${index + 1}')),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Container(
                      height: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    if (percentage != null)
                      Container(
                        width: constraints.maxWidth * percentage / 100,
                        height: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                percentage == null ? '—' : '${percentage.round()} %',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep {
  const _GuideStep(this.title, this.instruction, this.asset, this.legend);
  final String title;
  final String instruction;
  final String asset;
  final String legend;
}

const _guideSteps = <_GuideStep>[
  _GuideStep(
    'Mano abierta',
    'Relaja tu mano. Mantén las yemas separadas.',
    'assets/handsense/reposo.png',
    'El flexivo morado se ubica sobre el dorso del índice.',
  ),
  _GuideStep(
    'Acercar',
    'Acerca el índice. Flexiónalo sin tocar el pulgar.',
    'assets/handsense/flexion.png',
    'La flexión debe aparecer antes del contacto.',
  ),
  _GuideStep(
    'Pinza',
    'Junta las yemas. Realiza un contacto suave.',
    'assets/handsense/contacto.png',
    'El FSR marrón va en la yema del pulgar. El anillo verde indica el contacto esperado, no una medición.',
  ),
  _GuideStep(
    'Soltar',
    'Separa las yemas. Mantén el índice ligeramente flexionado.',
    'assets/handsense/liberacion.png',
    'Primero termina el contacto; después vuelve a reposo.',
  ),
  _GuideStep(
    'Retorno al reposo',
    'Vuelve al reposo. Regresa a la posición inicial.',
    'assets/handsense/retorno.png',
    'Una repetición termina al regresar a reposo.',
  ),
];

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key, required this.onPractice});
  final VoidCallback onPractice;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final item = _guideSteps[step];
    return PageContent(
      children: [
        Text(
          'Guía · Mano izquierda',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text('Paso ${step + 1} de ${_guideSteps.length}'),
        Semantics(
          liveRegion: true,
          label: 'Paso ${step + 1} de ${_guideSteps.length}',
          child: LinearProgressIndicator(
            value: (step + 1) / _guideSteps.length,
          ),
        ),
        Text(
          item.title,
          key: const ValueKey('guide-step-title'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        HandIllustration(
          asset: item.asset,
          semanticLabel: '${item.title}. ${item.instruction}',
          height: 250,
        ),
        Text(item.instruction, style: Theme.of(context).textTheme.bodyLarge),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('guide-previous'),
                onPressed: step == 0 ? null : () => setState(() => step--),
                child: const Text('Anterior'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const ValueKey('guide-next'),
                onPressed: step == _guideSteps.length - 1
                    ? widget.onPractice
                    : () => setState(() => step++),
                child: Text(
                  step == _guideSteps.length - 1
                      ? 'Preparar práctica'
                      : 'Siguiente',
                ),
              ),
            ),
          ],
        ),
        if (step == _guideSteps.length - 1)
          TextButton(
            key: const ValueKey('guide-repeat'),
            onPressed: () => setState(() => step = 0),
            child: const Text('Repetir guía'),
          ),
        const Text('La guía no genera intentos ni modifica los contadores.'),
      ],
    );
  }
}

class AttemptExplanation extends StatelessWidget {
  const AttemptExplanation({super.key, required this.attempt});
  final Attempt attempt;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Por qué se contó',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(attempt.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(attempt.explanation),
        const SizedBox(height: 8),
        Text(
          attempt.evaluable
              ? (attempt.complete
                    ? 'Clasificación: completa'
                    : 'Clasificación: incompleta')
              : 'Clasificación: no evaluable',
        ),
      ],
    ),
  );
}

class CounterSummary extends StatelessWidget {
  const CounterSummary({
    super.key,
    required this.complete,
    required this.incomplete,
    required this.unreliable,
  });
  final int complete, incomplete, unreliable;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final entry in {
        'Completas': complete,
        'Incompletas': incomplete,
        'No evaluables': unreliable,
      }.entries)
        Chip(label: Text('${entry.key}: ${entry.value}')),
    ],
  );
}

class PreparationScreen extends StatelessWidget {
  const PreparationScreen({
    super.key,
    required this.model,
    required this.onStart,
    required this.onDevice,
  });
  final SessionModel model;
  final VoidCallback onStart;
  final VoidCallback onDevice;

  @override
  Widget build(BuildContext context) {
    final ready = model.isDemo || model.readyForRealExercise;
    return PageContent(
      children: [
        heading(context, 'Preparar práctica'),
        SourceNotice(model: model),
        if (model.isDemo) ...[
          const HandIllustration(
            asset: 'assets/handsense/reposo.png',
            semanticLabel: 'Mano izquierda relajada, preparada para practicar',
          ),
          const Panel(
            child: Text(
              'Explora cómo funciona HandSense sin conectar sensores. Los resultados serán simulados y estarán identificados.',
            ),
          ),
        ] else ...[
          const HandIllustration(
            asset: 'assets/handsense/colocacion_dorsal.png',
            semanticLabel: 'Colocación sobre mano izquierda: flexivo morado en dorso del índice y FSR marrón en yema del pulgar',
          ),
          const Panel(
            child: Text(
              '1. Deja la mano en reposo.\n2. Comprueba que el soporte no tense los cables.\n3. Revisa que los sensores estén firmes y los cables libres.',
            ),
          ),
          TelemetryPanel(model: model),
          Panel(
            child: Text(
              ready
                  ? 'Preparado: conexión, telemetría reciente y reposo confirmado por el firmware.'
                  : 'Aún no se puede evaluar: se requieren conexión, datos recientes, señal evaluable y estado de reposo. Puedes revisar cada señal en Dispositivo.',
            ),
          ),
          if (!ready)
            OutlinedButton(
              key: const ValueKey('open-device-diagnostics'),
              onPressed: onDevice,
              child: const Text('Abrir diagnóstico'),
            ),
        ],
        FilledButton(
          key: const ValueKey('begin-exercise'),
          onPressed: ready ? onStart : null,
          child: Text(
            model.isDemo ? 'Explorar demostración' : 'Comenzar práctica',
          ),
        ),
      ],
    );
  }
}

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({
    super.key,
    required this.model,
    required this.onFinished,
  });
  final SessionModel model;
  final VoidCallback onFinished;
  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'La pinza, paso a paso'),
      SourceNotice(model: model),
      TelemetryPanel(model: model),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HandIllustration(
              asset: _exerciseAsset(model.telemetry?.phase),
              semanticLabel:
                  'Mano izquierda mostrando la etapa esperada de la pinza',
            ),
            const SizedBox(height: 12),
            const Text(
              'Flexiona el índice, realiza un contacto suave, libera el contacto y vuelve a reposo.',
            ),
            const SizedBox(height: 8),
            Text(
              model.sessionPaused
                  ? 'Evaluación pausada. Ningún evento se contará hasta reanudar desde reposo.'
                  : 'Evaluación activa. No necesitas tocar la pantalla entre repeticiones.',
            ),
          ],
        ),
      ),
      Semantics(
        liveRegion: true,
        child: Text(
          model.attempts.isEmpty
              ? (model.sessionPaused ? 'Estado: en pausa' : 'Estado: listo')
              : 'Estado del ejemplo: ${model.attempts.last.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      CounterSummary(
        complete: model.complete,
        incomplete: model.incomplete,
        unreliable: model.unreliable,
      ),
      _ExerciseActions(
        active: model.sessionActive,
        onPause: model.pauseSession,
        onResume: model.resumeSession,
        onFinished: onFinished,
      ),
      if (model.attempts.isNotEmpty)
        AttemptExplanation(attempt: model.attempts.last),
      if (model.canSimulate)
        Card(
          child: ExpansionTile(
            key: const ValueKey('demo-controls'),
            title: const Text('Explorar ejemplos simulados'),
            subtitle: const Text('Cinco escenarios de demostración'),
            children: [
              for (final outcome in Outcome.values)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      key: ValueKey('scenario-${outcome.name}'),
                      onPressed: () => model.simulate(outcome),
                      child: Text('Simular: ${Attempt(0, outcome).title}'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ExpansionTile(
        title: const Text('Comparar los dos conteos'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Flexión sola: ${model.flexOnly} · Fusión: ${model.complete}\nComparación ilustrativa de estos ejemplos. No mide la precisión del prototipo.',
            ),
          ),
        ],
      ),
      const Text('La sesión se conserva mientras esta app permanezca abierta.'),
    ],
  );

  static String _exerciseAsset(GesturePhase? phase) => switch (phase) {
    GesturePhase.flexion => 'assets/handsense/flexion.png',
    GesturePhase.contact => 'assets/handsense/contacto.png',
    GesturePhase.release => 'assets/handsense/liberacion.png',
    GesturePhase.waitForRest => 'assets/handsense/retorno.png',
    _ => 'assets/handsense/reposo.png',
  };
}

class _ExerciseActions extends StatelessWidget {
  const _ExerciseActions({
    required this.active,
    required this.onPause,
    required this.onResume,
    required this.onFinished,
  });
  final bool active;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    final pause = active
        ? OutlinedButton.icon(
            key: const ValueKey('pause-session'),
            onPressed: onPause,
            icon: const Icon(Icons.pause),
            label: const Text('Pausar'),
          )
        : FilledButton.icon(
            key: const ValueKey('resume-session'),
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Reanudar'),
          );
    final finish = FilledButton(
      key: const ValueKey('finish-session'),
      onPressed: onFinished,
      child: const Text('Finalizar'),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(1) >= 1.5;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [pause, const SizedBox(height: 8), finish],
          );
        }
        return Row(
          children: [
            Expanded(child: pause),
            const SizedBox(width: 12),
            Expanded(child: finish),
          ],
        );
      },
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.model});
  final SessionModel model;
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(24),
    itemCount: model.sessions.length + 1,
    itemBuilder: (context, index) {
      if (index == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading(context, 'Tus sesiones'),
            const SizedBox(height: 12),
            Text(
              model.isDemo
                  ? 'Historial temporal de demostración. Se pierde al cerrar la app.'
                  : 'Historial temporal de eventos BLE reales. Se pierde al cerrar la app.',
            ),
            const SizedBox(height: 12),
            if (model.attempts.isNotEmpty)
              const Text(
                'Tienes una sesión en curso en Ejercicio. Finalízala para verla aquí.',
              ),
            if (model.sessions.isEmpty)
              const Panel(
                child: Text(
                  'Todavía no hay sesiones finalizadas. Explora un ejemplo en Ejercicio y pulsa Finalizar y ver sesión.',
                ),
              ),
          ],
        );
      }
      final session = model.sessions[index - 1];
      return Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text('Sesión ${session.id} · ${session.source}'),
          subtitle: Text(
            '${session.attempts.length} intentos · ${session.complete} completos\n${session.finishedAt.day}/${session.finishedAt.month} · ${session.finishedAt.hour.toString().padLeft(2, '0')}:${session.finishedAt.minute.toString().padLeft(2, '0')}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text('Sesión ${session.id}')),
                body: SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: session.attempts.length + 1,
                    itemBuilder: (context, i) => i == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${session.source} · ${session.isDemo ? 'Datos simulados' : 'Origen del dispositivo'}',
                              ),
                              CounterSummary(
                                complete: session.complete,
                                incomplete: session.incomplete,
                                unreliable: session.unreliable,
                              ),
                            ],
                          )
                        : Card(
                            child: ExpansionTile(
                              key: ValueKey('history-attempt-$i'),
                              title: Text(
                                '$i. ${session.attempts[i - 1].title}',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: AttemptExplanation(
                                    attempt: session.attempts[i - 1],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({
    super.key,
    required this.session,
    required this.onHistory,
    required this.onHome,
  });
  final SessionRecord session;
  final VoidCallback onHistory;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'Resumen del ejercicio'),
      Text(
        session.isDemo
            ? 'Demostración · datos simulados'
            : 'Dispositivo · eventos confirmados por el firmware',
      ),
      CounterSummary(
        complete: session.complete,
        incomplete: session.incomplete,
        unreliable: session.unreliable,
      ),
      if (session.attempts.isEmpty)
        const Panel(
          child: Text('El ejercicio terminó sin intentos confirmados.'),
        )
      else
        AttemptExplanation(attempt: session.attempts.last),
      const Text(
        'Una interrupción o desconexión no se clasifica como un error de la persona.',
      ),
      FilledButton(
        key: const ValueKey('summary-history'),
        onPressed: onHistory,
        child: const Text('Ver historial'),
      ),
      TextButton(onPressed: onHome, child: const Text('Volver al inicio')),
    ],
  );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.available,
    this.showDivider = true,
  });
  final String label;
  final String value;
  final bool available;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(available ? Icons.check_circle : Icons.info_outline),
        title: Text(label),
        subtitle: Text(value),
      ),
      if (showDivider) const Divider(height: 1),
    ],
  );
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({
    super.key,
    required this.model,
    required this.largeText,
    required this.highContrast,
    required this.onLargeText,
    required this.onHighContrast,
    required this.onUseDevice,
    required this.onUseDemo,
    required this.onPing,
    required this.onResetDevice,
    required this.deviceCommandBusy,
    required this.communicationConfirmed,
    required this.onDisconnect,
    required this.onShowWelcome,
  });
  final SessionModel model;
  final bool largeText, highContrast;
  final ValueChanged<bool> onLargeText, onHighContrast;
  final VoidCallback onUseDevice;
  final VoidCallback onUseDemo;
  final VoidCallback onPing;
  final VoidCallback onResetDevice;
  final bool deviceCommandBusy;
  final bool communicationConfirmed;
  final VoidCallback onDisconnect;
  final VoidCallback onShowWelcome;
  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'Dispositivo y diagnóstico'),
      SourceNotice(model: model),
      Panel(
        child: Column(
          children: [
            _StatusRow(
              label: 'Bluetooth',
              value: model.isConnected ? 'Conectado' : 'Sin conexión',
              available: model.isConnected,
            ),
            _StatusRow(
              label: 'Comunicación',
              value: communicationConfirmed && model.isConnected
                  ? 'Comando confirmado'
                  : 'Sin comprobar',
              available: communicationConfirmed && model.isConnected,
            ),
            _StatusRow(
              label: 'Señales',
              value:
                  model.telemetryFresh &&
                      model.telemetry?.phase != GesturePhase.signalError
                  ? 'Evaluables'
                  : 'No evaluables',
              available:
                  model.telemetryFresh &&
                  model.telemetry?.phase != GesturePhase.signalError,
            ),
            _StatusRow(
              label: 'Práctica',
              value: model.readyForRealExercise ? 'Disponible' : 'Bloqueada',
              available: model.readyForRealExercise,
              showDivider: false,
            ),
          ],
        ),
      ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.connectionState.message,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (model.isDemo)
                  FilledButton.icon(
                    key: const ValueKey('connect-device'),
                    onPressed: onUseDevice,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Buscar HandSense'),
                  )
                else ...[
                  if (!model.isConnected)
                    FilledButton(
                      key: const ValueKey('retry-device'),
                      onPressed: onUseDevice,
                      child: const Text('Buscar otra vez'),
                    ),
                  OutlinedButton(
                    key: const ValueKey('disconnect-device'),
                    onPressed: onDisconnect,
                    child: const Text('Cancelar o desconectar'),
                  ),
                  OutlinedButton(
                    key: const ValueKey('use-demo'),
                    onPressed: onUseDemo,
                    child: const Text('Usar demostración'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      TelemetryPanel(model: model),
      if (!model.isDemo && model.isConnected)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comprobaciones del dispositivo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'PING comprueba el transporte BLE. RESET reinicia la sesión del firmware; ninguno confirma por sí solo que ambos sensores funcionen.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    key: const ValueKey('ping-device'),
                    onPressed: deviceCommandBusy ? null : onPing,
                    child: Text(
                      deviceCommandBusy ? 'Esperando…' : 'Enviar PING',
                    ),
                  ),
                  OutlinedButton(
                    key: const ValueKey('reset-device'),
                    onPressed: deviceCommandBusy ? null : onResetDevice,
                    child: const Text('Reiniciar sesión'),
                  ),
                ],
              ),
            ],
          ),
        ),
      heading(context, 'Accesibilidad'),
      const Text(
        'Se respeta el tamaño de texto de Android. Estas preferencias se conservan en este teléfono.',
      ),
      SwitchListTile(
        title: const Text('Texto más grande'),
        value: largeText,
        onChanged: onLargeText,
      ),
      SwitchListTile(
        title: const Text('Alto contraste'),
        value: highContrast,
        onChanged: onHighContrast,
      ),
      OutlinedButton(
        key: const ValueKey('calibration-info'),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Calibración pendiente'),
            scrollable: true,
            content: const Text(
              'La calibración se realiza actualmente por el monitor serie del ESP32. La app solo presenta telemetría recibida y no captura referencias ni confirma por sí sola que un sensor sea válido.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
        child: const Text('Acerca de la calibración'),
      ),
      TextButton.icon(
        key: const ValueKey('show-welcome'),
        onPressed: onShowWelcome,
        icon: const Icon(Icons.info_outline),
        label: const Text('Ver bienvenida y acerca de'),
      ),
      const Text(
        'HandSense · Alex Díaz y María José Córdoba\nPrototipo académico experimental. Sin validación clínica.',
      ),
    ],
  );
}
