import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handsense/main.dart';
import 'package:handsense/data/attempt.dart';
import 'package:handsense/ui/session_model.dart';
import 'package:handsense/ui/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDeviceSource implements AttemptSource, DeviceControls {
  final attempts = StreamController<Attempt>.broadcast(sync: true);
  final states = StreamController<HandSenseConnectionState>.broadcast(
    sync: true,
  );
  final readings = StreamController<DeviceTelemetry>.broadcast(sync: true);
  HandSenseConnectionState current = const HandSenseConnectionState(
    DeviceConnectionPhase.connected,
    'Conectado para prueba.',
  );

  @override
  Stream<Attempt> get events => attempts.stream;
  @override
  String get label => 'Dispositivo de prueba';
  @override
  bool get isDemo => false;
  @override
  Stream<HandSenseConnectionState> get connectionStates => states.stream;
  @override
  Stream<DeviceTelemetry> get telemetry => readings.stream;
  @override
  HandSenseConnectionState get connectionState => current;
  @override
  Future<void> connect() async {}
  @override
  Future<void> disconnect() async {
    current = const HandSenseConnectionState(
      DeviceConnectionPhase.disconnected,
      'Desconectado para prueba.',
    );
    states.add(current);
  }

  @override
  Future<bool> ping() async => true;
  @override
  Future<bool> resetDeviceSession() async => true;
  @override
  void dispose() {
    attempts.close();
    states.close();
    readings.close();
  }
}

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  // HandSense carga preferencias antes de construir la navegación. Esperar ese
  // estado evita tratar la pantalla de carga como si fuera una lista vacía.
  await tester.pumpAndSettle();

  // ListView builds off-screen children lazily. Scroll to create the target
  // before ensureVisible tries to access its Element.
  if (target.evaluate().isEmpty) {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) {
      throw TestFailure(
        'No se encontró el objetivo y la pantalla actual no contiene un '
        'Scrollable donde buscarlo: $target',
      );
    }
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: scrollables.first,
      maxScrolls: 50,
    );
  }
  expect(target, findsAtLeastNWidgets(1));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'welcomeCompleted': true});
  });

  testWidgets('primera apertura muestra bienvenida y luego abre inicio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'welcomeCompleted': true});
    await tester.pumpWidget(const HandSenseApp());
    await tester.pumpAndSettle();
    expect(find.text('HandSense'), findsOneWidget);
    expect(find.text('Movimiento con sentido'), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome-start')), findsOneWidget);
    expect(find.text('Señales en tiempo real'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('welcome-start')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('start-demo')), findsOneWidget);
  });

  testWidgets('bienvenida no reaparece al navegar durante el arranque', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('welcome-start')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('nav-1')));
    await tapVisible(tester, find.byKey(const ValueKey('nav-0')));
    expect(find.byKey(const ValueKey('welcome-start')), findsNothing);
    expect(find.byKey(const ValueKey('start-demo')), findsOneWidget);
  });

  testWidgets('dashboard real vacío muestra porcentaje indefinido', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('dashboard-percentage')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Aún no hay sesiones reales registradas.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dashboard-percentage')),
        matching: find.text('—'),
      ),
      findsOneWidget,
    );
  });

  test('dashboard calcula evaluables y separa real de demostración', () {
    final records = [
      SessionRecord(
        1,
        DateTime(2026, 11, 26, 10),
        'Dispositivo HandSense',
        false,
        const [
          Attempt(1, Outcome.complete),
          Attempt(2, Outcome.noContact),
          Attempt(3, Outcome.unreliable),
        ],
      ),
      SessionRecord(2, DateTime(2026, 11, 26, 11), 'Demostración', true, const [
        Attempt(4, Outcome.complete),
        Attempt(5, Outcome.complete),
      ]),
    ];

    final real = ActivitySummary.fromSessions(records, demo: false);
    final demo = ActivitySummary.fromSessions(records, demo: true);
    expect(real.sessionCount, 1);
    expect(real.complete, 1);
    expect(real.incomplete, 1);
    expect(real.evaluable, 2);
    expect(real.completionPercentage, 50);
    expect(demo.sessionCount, 1);
    expect(demo.complete, 2);
    expect(demo.incomplete, 0);
    expect(demo.completionPercentage, 100);
  });

  testWidgets('dashboard demo se actualiza al guardar una sesión', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('start-demo')));
    await tapVisible(tester, find.byKey(const ValueKey('begin-exercise')));
    await tapVisible(tester, find.byKey(const ValueKey('demo-controls')));
    await tapVisible(tester, find.byKey(const ValueKey('scenario-complete')));
    await tapVisible(tester, find.byKey(const ValueKey('finish-session')));
    await tapVisible(tester, find.text('Volver al inicio'));
    await tapVisible(tester, find.byKey(const ValueKey('activity-demo')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('dashboard-percentage')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sesiones registradas'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(find.textContaining('Demostración · 1 registros'), findsOneWidget);
  });

  test('pares críticos cumplen contraste AA', () {
    for (final highContrast in [false, true]) {
      final scheme = handSenseColorScheme(highContrast: highContrast);
      expect(
        contrastRatio(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(scheme.secondaryContainer, scheme.onSecondaryContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(scheme.surface, scheme.onSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(scheme.surface, scheme.onSurfaceVariant),
        greaterThanOrEqualTo(4.5),
      );
      final theme = handSenseTheme(highContrast: highContrast);
      final selectedLabel = theme.navigationBarTheme.labelTextStyle!.resolve({
        WidgetState.selected,
      })!;
      expect(selectedLabel.color, scheme.onSurface);
      expect(
        contrastRatio(
          theme.navigationBarTheme.backgroundColor!,
          selectedLabel.color!,
        ),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
  test('cinco escenarios, archivo inmutable y nueva sesión independiente', () {
    final model = SessionModel(DemoRepository());
    addTearDown(model.dispose);
    model.beginSession();
    for (final outcome in Outcome.values) {
      model.simulate(outcome);
    }
    expect(model.complete, 1);
    expect(model.incomplete, 3);
    expect(model.unreliable, 1);
    expect(model.flexOnly, 2);
    expect(() => model.attempts.clear(), throwsUnsupportedError);
    model.finish();
    expect(model.attempts, isEmpty);
    expect(model.sessions.single.attempts.length, 5);
    expect(model.sessions.single.isDemo, isTrue);
    expect(
      () => model.sessions.single.attempts.clear(),
      throwsUnsupportedError,
    );
    model.finish();
    expect(model.sessions.length, 1);
    model.beginSession();
    model.simulate(Outcome.unreliable);
    expect(model.incomplete, 0);
    expect(model.unreliable, 1);
    expect(model.sessions.single.complete, 1);
  });
  testWidgets('navegación, escenario y explicación conservada en historial', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tester.pumpAndSettle();
    expect(find.text('Movimiento con sentido'), findsOneWidget);
    expect(find.text('Simular: Pinza completa'), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('start-demo')));
    expect(find.textContaining('Datos simulados'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('begin-exercise')));
    await tapVisible(tester, find.byKey(const ValueKey('demo-controls')));
    await tapVisible(tester, find.byKey(const ValueKey('scenario-complete')));
    await tester.scrollUntilVisible(
      find.text('Completas: 1'),
      -200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 50,
    );
    expect(find.text('Completas: 1'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('finish-session')));
    await tapVisible(tester, find.byKey(const ValueKey('summary-history')));
    expect(find.text('Tus sesiones'), findsOneWidget);
    await tapVisible(tester, find.text('Sesión 1 · Demostración'));
    await tapVisible(tester, find.byKey(const ValueKey('history-attempt-1')));
    expect(find.text('Por qué se contó'), findsOneWidget);
    expect(
      find.textContaining('Se registraron flexión y contacto'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('nav-3')));
    await tapVisible(tester, find.byKey(const ValueKey('calibration-info')));
    expect(find.text('Calibración pendiente'), findsOneWidget);
    await tapVisible(tester, find.text('Entendido'));
    expect(tester.takeException(), isNull);
  });
  testWidgets('la guía no genera intentos y permite recorrer cinco pasos', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tapVisible(tester, find.byKey(const ValueKey('open-guide')));
    expect(find.text('Guía · Mano izquierda'), findsOneWidget);
    expect(find.textContaining('Mano derecha'), findsNothing);
    expect(find.text('Mano abierta'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('guide-next')));
    }
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('guide-step-title'), skipOffstage: false),
          )
          .data,
      'Retorno al reposo',
    );
    expect(find.text('Preparar práctica'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('guide-repeat')));
    expect(find.text('Mano abierta'), findsOneWidget);
    expect(find.textContaining('Completas:'), findsNothing);
    for (var i = 0; i < 4; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('guide-next')));
    }
    await tapVisible(tester, find.byKey(const ValueKey('guide-next')));
    expect(find.text('Preparación'), findsOneWidget);
  });

  testWidgets('preferencias de accesibilidad persisten juntas', (tester) async {
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('nav-3')));
    await tapVisible(tester, find.text('Texto más grande'));
    await tapVisible(tester, find.text('Alto contraste'));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('nav-3')));
    final switches = tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switches.map((item) => item.value), everyElement(isTrue));
    expect(tester.takeException(), isNull);
  });

  test('una sesión pausada descarta eventos de demostración', () {
    final model = SessionModel(DemoRepository());
    addTearDown(model.dispose);
    model.beginSession();
    model.simulate(Outcome.complete);
    expect(model.complete, 1);
    model.pauseSession();
    model.simulate(Outcome.complete);
    expect(model.complete, 1);
    expect(model.sessionPaused, isTrue);
  });

  test('señal no evaluable o desconexión impiden conteos reales', () async {
    final source = FakeDeviceSource();
    final model = SessionModel(source);
    addTearDown(model.dispose);
    source.readings.add(DeviceTelemetry(70, 0, GesturePhase.signalError));
    model.beginSession();
    source.attempts.add(const Attempt(1, Outcome.complete));
    expect(model.complete, 0);
    expect(model.sessionPaused, isTrue);

    source.readings.add(DeviceTelemetry(10, 10, GesturePhase.rest));
    expect(model.resumeSession(), isTrue);
    source.attempts.add(const Attempt(2, Outcome.complete));
    expect(model.complete, 1);

    await source.disconnect();
    source.attempts.add(const Attempt(3, Outcome.complete));
    expect(model.complete, 1);
    expect(model.sessionPaused, isTrue);
  });
  for (final size in [const Size(320, 640), const Size(800, 600)]) {
    testWidgets('cuatro secciones con texto 200% en $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const HandSenseApp(showWelcomeOnLaunch: false));
      for (var i = 0; i < 4; i++) {
        await tapVisible(tester, find.byKey(ValueKey('nav-$i')));
        expect(tester.takeException(), isNull);
      }
      await tapVisible(tester, find.text('Texto más grande'));
      await tapVisible(tester, find.text('Alto contraste'));
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byKey(const ValueKey('nav-0')));
      expect(tester.takeException(), isNull);
    });
  }
}
