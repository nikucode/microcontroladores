import 'package:flutter/material.dart';

import 'data/attempt.dart';
import 'data/ble_attempt_source.dart';
import 'ui/session_model.dart';
import 'ui/screens.dart';

void main() => runApp(const HandSenseApp());

class HandSenseApp extends StatefulWidget {
  const HandSenseApp({super.key});
  @override
  State<HandSenseApp> createState() => _HandSenseAppState();
}

class _HandSenseAppState extends State<HandSenseApp> {
  final model = SessionModel(DemoRepository());
  int page = 0;
  bool largeText = false;
  bool highContrast = false;
  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _useDevice(BuildContext context) async {
    await model.replaceSource(BleAttemptSource());
    await model.connect();
    if (!context.mounted) return;
    if (model.connectionState.phase == DeviceConnectionPhase.error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(model.connectionState.message)));
    }
  }

  Future<void> _useDemo() => model.replaceSource(DemoRepository());

  Future<void> _ping(BuildContext context) async {
    final acknowledged = await model.ping();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          acknowledged
              ? 'El ESP32 confirmó PING.'
              : 'No llegó la confirmación del ESP32 en 3 segundos.',
        ),
      ),
    );
  }

  Future<void> _resetDevice(BuildContext context) async {
    final acknowledged = await model.resetDeviceSession();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          acknowledged
              ? 'El ESP32 reinició la sesión y confirmó el comando.'
              : 'El ESP32 no confirmó el reinicio en 3 segundos.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HandSense',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245c4b),
        contrastLevel: highContrast ? 1 : 0,
      ),
      scaffoldBackgroundColor: highContrast
          ? Colors.white
          : const Color(0xfff6f5ef),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 52)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 52)),
      ),
    ),
    builder: (context, child) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          textScaler: largeText
              ? TextScaler.linear(media.textScaler.scale(1) * 1.25)
              : media.textScaler,
        ),
        child: child!,
      );
    },
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('HandSense')),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: model,
            builder: (context, _) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: switch (page) {
                  0 => HomeScreen(
                    model: model,
                    onExercise: () => setState(() => page = 1),
                    onUseDevice: () => _useDevice(context),
                    onUseDemo: _useDemo,
                    onPing: () => _ping(context),
                    onResetDevice: () => _resetDevice(context),
                  ),
                  1 => ExerciseScreen(
                    model: model,
                    onFinished: () {
                      model.finish();
                      setState(() => page = 2);
                    },
                  ),
                  2 => HistoryScreen(model: model),
                  _ => SettingsScreen(
                    model: model,
                    largeText: largeText,
                    highContrast: highContrast,
                    onLargeText: (value) => setState(() => largeText = value),
                    onHighContrast: (value) =>
                        setState(() => highContrast = value),
                  ),
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 4; i++)
                    Semantics(
                      selected: page == i,
                      child: TextButton.icon(
                        key: ValueKey('nav-$i'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          backgroundColor: page == i
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : null,
                        ),
                        onPressed: () => setState(() => page = i),
                        icon: Icon(
                          [
                            Icons.home_outlined,
                            Icons.touch_app_outlined,
                            Icons.history,
                            Icons.settings_outlined,
                          ][i],
                        ),
                        label: Text(
                          ['Inicio', 'Ejercicio', 'Historial', 'Ajustes'][i],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
