import 'package:flutter/material.dart';

import 'data/attempt.dart';
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
                  0 => HomeScreen(onExercise: () => setState(() => page = 1)),
                  1 => ExerciseScreen(
                    model: model,
                    onFinished: () {
                      model.finish();
                      setState(() => page = 2);
                    },
                  ),
                  2 => HistoryScreen(model: model),
                  _ => SettingsScreen(
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
