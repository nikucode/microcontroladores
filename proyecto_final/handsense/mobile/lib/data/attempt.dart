enum Outcome { complete, noContact, noFlexion, noRelease, unreliable }

class Attempt {
  const Attempt(this.id, this.outcome);
  final int id;
  final Outcome outcome;
  bool get complete => outcome == Outcome.complete;
  bool get evaluable => outcome != Outcome.unreliable;
  bool get flexCycle =>
      outcome == Outcome.complete || outcome == Outcome.noContact;
  String get title => switch (outcome) {
    Outcome.complete => 'Pinza completa',
    Outcome.noContact => 'Faltó contacto',
    Outcome.noFlexion => 'Faltó flexión',
    Outcome.noRelease => 'Faltó liberación',
    Outcome.unreliable => 'No evaluable',
  };
  String get explanation => switch (outcome) {
    Outcome.complete => 'Se registraron flexión y contacto, seguidos de liberación y regreso a reposo.',
    Outcome.noContact => 'Se registró un ciclo de flexión, pero no contacto. Si sí hubo contacto, revisa el ajuste y la calibración.',
    Outcome.noFlexion => 'Se registró contacto, pero no suficiente flexión según los límites del ejemplo.',
    Outcome.noRelease => 'El contacto permaneció activo hasta terminar el tiempo del ejemplo. No se contó una repetición completa.',
    Outcome.unreliable => 'La señal del ejemplo no permite interpretar el intento. Esto no significa que el movimiento haya sido incorrecto.',
  };
}

abstract class AttemptRepository {
  List<Attempt> get attempts;
  void simulate(Outcome outcome);
  void clear();
}

// Ejemplos de resultados; no ejecuta ni valida el clasificador del ESP32.
class DemoRepository implements AttemptRepository {
  final List<Attempt> _attempts = [];
  @override
  List<Attempt> get attempts => List.unmodifiable(_attempts);
  @override
  void simulate(Outcome outcome) =>
      _attempts.add(Attempt(_attempts.length + 1, outcome));
  @override
  void clear() => _attempts.clear();
}
