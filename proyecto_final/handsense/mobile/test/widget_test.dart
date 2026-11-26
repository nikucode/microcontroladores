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
  // ListView builds off-screen children lazily. Scroll to create the target
  // before ensureVisible tries to access its Element.
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 50,
    );
  }
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
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HandSenseApp());
    await tester.pumpAndSettle();
    expect(find.text('HandSense'), findsOneWidget);
    expect(find.text('Movimiento con sentido'), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome-start')), findsOneWidget);
    expect(find.text('Señales en tiempo real'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('welcome-start')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('start-demo')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const HandSenseApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('welcome-start')), findsNothing);
    expect(find.byKey(const ValueKey('start-demo')), findsOneWidget);
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
    await tester.pumpWidget(const HandSenseApp());
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
    await tester.pumpWidget(const HandSenseApp());
    await tapVisible(tester, find.byKey(const ValueKey('open-guide')));
    expect(find.text('Mano abierta'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('guide-next')));
    }
    expect(find.text('Retorno al reposo'), findsOneWidget);
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
    await tester.pumpWidget(const HandSenseApp());
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('nav-3')));
    await tapVisible(tester, find.text('Texto más grande'));
    await tapVisible(tester, find.text('Alto contraste'));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const HandSenseApp());
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
      await tester.pumpWidget(const HandSenseApp());
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
