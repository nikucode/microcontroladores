import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/attempt.dart';
import 'data/ble_attempt_source.dart';
import 'ui/session_model.dart';
import 'ui/screens.dart';
import 'ui/app_theme.dart';

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
  bool deviceCommandBusy = false;
  bool communicationConfirmed = false;
  bool preferencesReady = false;
  bool showWelcome = true;
  int flow = 0;
  SessionRecord? summary;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      showWelcome = !(preferences.getBool('welcomeCompleted') ?? false);
      largeText = preferences.getBool('largeText') ?? false;
      highContrast = preferences.getBool('highContrast') ?? false;
      preferencesReady = true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  Future<void> _completeWelcome() async {
    setState(() => showWelcome = false);
    await _savePreference('welcomeCompleted', true);
  }

  void _setLargeText(bool value) {
    setState(() => largeText = value);
    _savePreference('largeText', value);
  }

  void _setHighContrast(bool value) {
    setState(() => highContrast = value);
    _savePreference('highContrast', value);
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _useDevice(BuildContext context) async {
    setState(() => communicationConfirmed = false);
    if (model.isDemo) await model.replaceSource(BleAttemptSource());
    await model.connect();
    if (!context.mounted) return;
    if (model.connectionState.phase == DeviceConnectionPhase.error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(model.connectionState.message)));
    }
  }

  Future<void> _useDemo() => model.replaceSource(DemoRepository());

  void _openPreparation() => setState(() => flow = 1);

  void _startExercise() {
    model.beginSession();
    setState(() => flow = 2);
  }

  void _finishExercise() {
    summary = model.finish();
    setState(() {
      flow = summary == null ? 0 : 3;
      page = 2;
    });
  }

  Future<void> _ping(BuildContext context) async {
    if (deviceCommandBusy) return;
    setState(() => deviceCommandBusy = true);
    final bool acknowledged;
    try {
      acknowledged = await model.ping();
    } finally {
      if (mounted) setState(() => deviceCommandBusy = false);
    }
    if (acknowledged && mounted) {
      setState(() => communicationConfirmed = true);
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
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
    if (deviceCommandBusy) return;
    setState(() => deviceCommandBusy = true);
    final bool acknowledged;
    try {
      acknowledged = await model.resetDeviceSession();
    } finally {
      if (mounted) setState(() => deviceCommandBusy = false);
    }
    if (acknowledged && mounted) {
      setState(() => communicationConfirmed = true);
    }
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          acknowledged
              ? 'El ESP32 reinició la sesión y confirmó el comando.'
              : 'El ESP32 no confirmó el reinicio tras el reintento.',
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sobre HandSense'),
      content: const Text(
        'HandSense es un prototipo universitario experimental que combina señales de flexión y contacto para explicar una secuencia de pinza. No posee validación clínica.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );

  void _showAccessibility(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: StatefulBuilder(
        builder: (context, updateSheet) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accesibilidad',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Texto más grande'),
                value: largeText,
                onChanged: (value) {
                  _setLargeText(value);
                  updateSheet(() {});
                },
              ),
              SwitchListTile(
                title: const Text('Alto contraste'),
                value: highContrast,
                onChanged: (value) {
                  _setHighContrast(value);
                  updateSheet(() {});
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Listo'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HandSense',
    debugShowCheckedModeBanner: false,
    theme: handSenseTheme(highContrast: highContrast),
    builder: (context, child) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          textScaler: largeText
              ? TextScaler.linear(
                  media.textScaler.scale(1) < 1.25
                      ? 1.25
                      : media.textScaler.scale(1),
                )
              : media.textScaler,
        ),
        child: child!,
      );
    },
    home: Builder(
      builder: (context) {
        if (!preferencesReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (showWelcome) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: WelcomeScreen(
                    onStart: _completeWelcome,
                    onAbout: () => _showAbout(context),
                    onAccessibility: () => _showAccessibility(context),
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              flow == 0
                  ? 'HandSense'
                  : ['', 'Preparación', 'Ejercicio', 'Resumen'][flow],
            ),
            leading: flow == 0
                ? null
                : IconButton(
                    tooltip: 'Volver',
                    onPressed: () {
                      if (flow == 2) model.pauseSession();
                      setState(() => flow = 0);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          body: SafeArea(
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: flow != 0
                      ? switch (flow) {
                          1 => PreparationScreen(
                            model: model,
                            onStart: _startExercise,
                            onDevice: () => setState(() {
                              flow = 0;
                              page = 3;
                            }),
                          ),
                          2 => ExerciseScreen(
                            model: model,
                            onFinished: _finishExercise,
                          ),
                          _ => SessionSummaryScreen(
                            session: summary!,
                            onHistory: () => setState(() {
                              flow = 0;
                              page = 2;
                            }),
                            onHome: () => setState(() {
                              flow = 0;
                              page = 0;
                            }),
                          ),
                        }
                      : switch (page) {
                          0 => HomeScreen(
                            model: model,
                            onExercise: _openPreparation,
                            onGuide: () => setState(() => page = 1),
                            onUseDevice: () => _useDevice(context),
                            onUseDemo: _useDemo,
                          ),
                          1 => GuideScreen(onPractice: _openPreparation),
                          2 => HistoryScreen(model: model),
                          _ => DeviceScreen(
                            model: model,
                            largeText: largeText,
                            highContrast: highContrast,
                            onLargeText: _setLargeText,
                            onHighContrast: _setHighContrast,
                            onUseDevice: () => _useDevice(context),
                            onUseDemo: _useDemo,
                            onPing: () => _ping(context),
                            onResetDevice: () => _resetDevice(context),
                            deviceCommandBusy: deviceCommandBusy,
                            communicationConfirmed: communicationConfirmed,
                            onDisconnect: model.disconnect,
                            onShowWelcome: () =>
                                setState(() => showWelcome = true),
                          ),
                        },
                ),
              ),
            ),
          ),
          bottomNavigationBar: flow != 0
              ? null
              : NavigationBar(
                  selectedIndex: page,
                  labelBehavior:
                      MediaQuery.textScalerOf(context).scale(1) >= 1.5
                      ? NavigationDestinationLabelBehavior.onlyShowSelected
                      : NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (value) =>
                      setState(() => page = value),
                  destinations: const [
                    NavigationDestination(
                      key: ValueKey('nav-0'),
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-1'),
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: 'Guía',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-2'),
                      icon: Icon(Icons.history),
                      label: 'Historial',
                    ),
                    NavigationDestination(
                      key: ValueKey('nav-3'),
                      icon: Icon(Icons.sensors_outlined),
                      selectedIcon: Icon(Icons.sensors),
                      label: 'Equipo',
                    ),
                  ],
                ),
        );
      },
    ),
  );
}
