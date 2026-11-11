import 'package:flutter_test/flutter_test.dart';
import 'package:handsense/main.dart';
import 'package:handsense/data/attempt.dart';
import 'package:handsense/ui/session_model.dart';

void main() {
  test('no evaluable no penaliza ni aumenta los conteos de movimiento', () {
    final model = SessionModel(DemoRepository());
    addTearDown(model.dispose);
    model.simulate(Outcome.complete);
    model.simulate(Outcome.noContact);
    model.simulate(Outcome.unreliable);
    expect(model.complete, 1);
    expect(model.incomplete, 1);
    expect(model.unreliable, 1);
    expect(model.flexOnly, 2);
    expect(() => model.attempts.clear(), throwsUnsupportedError);
    model.reset();
    expect(model.attempts, isEmpty);
  });
  testWidgets('muestra origen simulado y permite generar un intento', (
    tester,
  ) async {
    await tester.pumpWidget(const HandSenseApp());
    expect(find.textContaining('Datos simulados'), findsOneWidget);
    await tester.tap(find.text('Simular: Pinza completa'));
    await tester.pump();
    expect(find.textContaining('Completas: 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('texto ampliado conserva controles sin desbordes', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const HandSenseApp());
    expect(tester.takeException(), isNull);
  });
}
