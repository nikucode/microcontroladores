import 'package:flutter/material.dart';

import 'data/attempt.dart';
import 'ui/session_model.dart';

void main() => runApp(const HandSenseApp());

class HandSenseApp extends StatefulWidget {
  const HandSenseApp({super.key});
  @override
  State<HandSenseApp> createState() => _HandSenseAppState();
}

class _HandSenseAppState extends State<HandSenseApp> {
  final model = SessionModel(DemoRepository());
  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HandSense',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff31775f)),
      useMaterial3: true,
    ),
    home: Scaffold(
      appBar: AppBar(title: const Text('HandSense')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Por qué se contó',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'DEMOSTRACIÓN · Datos simulados\nExplora ejemplos de intentos. BLE y almacenamiento persistente todavía no están implementados.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Completas: ${model.complete} · Incompletas: ${model.incomplete}\nNo evaluables: ${model.unreliable}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Conteo por flexión: ${model.flexOnly} · Por fusión: ${model.complete}',
              ),
              const Text(
                'Comparación ilustrativa. No son mediciones físicas ni una prueba de precisión.',
              ),
              const SizedBox(height: 20),
              for (final outcome in Outcome.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => model.simulate(outcome),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Simular: ${Attempt(0, outcome).title}'),
                    ),
                  ),
                ),
              if (model.attempts.isNotEmpty)
                Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Último resultado: ${model.attempts.last.title}',
                    ),
                  ),
                ),
              const Divider(),
              Text(
                'Intentos de esta demostración',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Se pierden al cerrar la aplicación. Cada intento explica las señales del ejemplo, no tu capacidad.',
              ),
              for (final attempt in model.attempts.reversed)
                Card(
                  child: ExpansionTile(
                    key: ValueKey(attempt),
                    title: Text('Intento ${attempt.id}: ${attempt.title}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(attempt.explanation),
                      ),
                    ],
                  ),
                ),
              TextButton(
                onPressed: model.attempts.isEmpty ? null : model.reset,
                child: const Text('Borrar demostración'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
