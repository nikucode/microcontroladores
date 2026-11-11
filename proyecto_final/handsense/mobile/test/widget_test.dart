import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handsense/main.dart';
import 'package:handsense/data/attempt.dart';
import 'package:handsense/ui/session_model.dart';

Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  test('cinco escenarios, archivo inmutable y nueva sesión independiente', () {
    final model = SessionModel(DemoRepository());
    addTearDown(model.dispose);
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
    model.simulate(Outcome.unreliable);
    expect(model.incomplete, 0);
    expect(model.unreliable, 1);
    expect(model.sessions.single.complete, 1);
  });
  testWidgets('navegación, escenario y explicación conservada en historial', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp());
    expect(find.text('Comprende cada intento'), findsOneWidget);
    expect(find.text('Simular: Pinza completa'), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('start-demo')));
    await tapVisible(tester, find.byKey(const ValueKey('demo-controls')));
    await tapVisible(tester, find.byKey(const ValueKey('scenario-complete')));
    expect(find.text('Completas: 1'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('finish-session')));
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
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byKey(const ValueKey('nav-0')));
      expect(tester.takeException(), isNull);
    });
  }
}
