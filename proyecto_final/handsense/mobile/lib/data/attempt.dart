import 'dart:async';

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

// Una fuente BLE futura publicará eventos verificados en este mismo flujo.
abstract class AttemptSource {
  Stream<Attempt> get events;
  String get label;
  bool get isDemo;
  void dispose();
}

enum DeviceConnectionPhase {
  idle,
  requestingPermission,
  scanning,
  connecting,
  connected,
  disconnected,
  error,
}

class HandSenseConnectionState {
  const HandSenseConnectionState(this.phase, this.message, {this.deviceName});

  final DeviceConnectionPhase phase;
  final String message;
  final String? deviceName;

  bool get connected => phase == DeviceConnectionPhase.connected;
}

/// Capacidades exclusivas de una fuente física. La demostración no implementa
/// esta interfaz, por lo que sus datos nunca se confunden con mediciones BLE.
abstract class DeviceControls {
  Stream<HandSenseConnectionState> get connectionStates;
  HandSenseConnectionState get connectionState;
  Future<void> connect();
  Future<void> disconnect();
  Future<bool> ping();
}

abstract class DemoControls {
  void simulate(Outcome outcome);
}

class DemoRepository implements AttemptSource, DemoControls {
  final _events = StreamController<Attempt>.broadcast(sync: true);
  int _nextId = 0;
  @override
  Stream<Attempt> get events => _events.stream;
  @override
  String get label => 'Demostración';
  @override
  bool get isDemo => true;
  @override
  void simulate(Outcome outcome) => _events.add(Attempt(++_nextId, outcome));
  @override
  void dispose() => _events.close();
}

class SessionRecord {
  SessionRecord(
    this.id,
    this.finishedAt,
    this.source,
    this.isDemo,
    List<Attempt> attempts,
  ) : attempts = List.unmodifiable(attempts);
  final int id;
  final DateTime finishedAt;
  final String source;
  final bool isDemo;
  final List<Attempt> attempts;
  int get complete => attempts.where((a) => a.complete).length;
  int get incomplete =>
      attempts.where((a) => a.evaluable && !a.complete).length;
  int get unreliable => attempts.where((a) => !a.evaluable).length;
}
