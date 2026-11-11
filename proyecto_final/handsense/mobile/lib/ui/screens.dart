import 'package:flutter/material.dart';

import '../data/attempt.dart';
import 'session_model.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      for (final child in children)
        Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
    ],
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

Widget heading(BuildContext context, String text) =>
    Text(text, style: Theme.of(context).textTheme.headlineMedium);
const demoNotice = Text(
  'Demostración · Datos simulados. Sin conexión con sensores físicos.',
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onExercise});
  final VoidCallback onExercise;
  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'Comprende cada intento'),
      const Text(
        'HandSense observa flexión y contacto para explicar cómo se completa una pinza entre pulgar e índice.',
      ),
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              semanticLabel: 'Dispositivo sin conectar',
            ),
            SizedBox(height: 8),
            Text(
              'Dispositivo: sin conectar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'La conexión BLE estará disponible en una próxima etapa. Hoy puedes explorar ejemplos.',
            ),
          ],
        ),
      ),
      FilledButton.icon(
        key: const ValueKey('start-demo'),
        onPressed: onExercise,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Explorar el ejercicio'),
      ),
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por qué se contó',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Cada resultado explica las señales observadas. Un problema de señal se muestra como no evaluable, sin juzgar la capacidad de la persona.',
            ),
          ],
        ),
      ),
      demoNotice,
    ],
  );
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
      demoNotice,
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.pinch_outlined,
              size: 64,
              semanticLabel: 'Ilustración simbólica de la pinza pulgar–índice',
            ),
            SizedBox(height: 12),
            Text(
              '1. Comienza con pulgar e índice separados.\n2. Acerca ambos dedos hasta el contacto.\n3. Suelta el contacto y vuelve a reposo.',
            ),
            SizedBox(height: 8),
            Text(
              'Esta guía describe la secuencia del prototipo; los botones de abajo generan ejemplos completos de resultados.',
            ),
          ],
        ),
      ),
      Semantics(
        liveRegion: true,
        child: Text(
          model.attempts.isEmpty
              ? 'Estado: listo para explorar'
              : 'Estado del ejemplo: ${model.attempts.last.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      CounterSummary(
        complete: model.complete,
        incomplete: model.incomplete,
        unreliable: model.unreliable,
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
      FilledButton(
        key: const ValueKey('finish-session'),
        onPressed: model.attempts.isEmpty ? null : onFinished,
        child: const Text('Finalizar y ver sesión'),
      ),
      const Text('La sesión se conserva mientras esta app permanezca abierta.'),
    ],
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.model});
  final SessionModel model;
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: model.sessions.length + 1,
    itemBuilder: (context, index) {
      if (index == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading(context, 'Tus sesiones'),
            const SizedBox(height: 12),
            const Text(
              'Historial temporal de demostración. Se pierde al cerrar la app.',
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
                    padding: const EdgeInsets.all(20),
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
                        : AttemptExplanation(attempt: session.attempts[i - 1]),
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.largeText,
    required this.highContrast,
    required this.onLargeText,
    required this.onHighContrast,
  });
  final bool largeText, highContrast;
  final ValueChanged<bool> onLargeText, onHighContrast;
  @override
  Widget build(BuildContext context) => PageContent(
    children: [
      heading(context, 'A tu manera'),
      const Text(
        'Se respeta el tamaño de texto de Android. Estas preferencias duran mientras la app está abierta.',
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
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dispositivo', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Sin conexión BLE. No hay mediciones físicas disponibles.'),
          ],
        ),
      ),
      OutlinedButton(
        key: const ValueKey('calibration-info'),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Calibración pendiente'),
            scrollable: true,
            content: const Text(
              'Cuando se integre el ESP32, esta sección guiará el registro de reposo y un gesto cómodo para ajustar los rangos. Hoy no podemos calibrar ni confirmar sensores desde la app.',
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
      const Text(
        'HandSense · Alex Díaz y María José Córdova\nPrototipo académico experimental. Sin validación clínica.',
      ),
    ],
  );
}
