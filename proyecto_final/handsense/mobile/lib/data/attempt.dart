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
    Outcome.noFlexion =>
      'Se registró contacto, pero la flexión no alcanzó el rango configurado.',
    Outcome.noRelease => 'El contacto permaneció activo hasta terminar la ventana del intento. No se contó una repetición completa.',
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

enum GesturePhase { rest, flexion, contact, release, waitForRest, signalError }

class DeviceTelemetry {
  DeviceTelemetry(
    this.flexionPercent,
    this.contactPercent,
    this.phase, {
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  final int flexionPercent;
  final int contactPercent;
  final GesturePhase phase;
  final DateTime receivedAt;

  String get phaseLabel => switch (phase) {
    GesturePhase.rest => 'Reposo',
    GesturePhase.flexion => 'Flexión',
    GesturePhase.contact => 'Contacto',
    GesturePhase.release => 'Liberación',
    GesturePhase.waitForRest => 'Espera volver a reposo',
    GesturePhase.signalError => 'Señal no evaluable',
  };
}

/// Capacidades exclusivas de una fuente física. La demostración no implementa
/// esta interfaz, por lo que sus datos nunca se confunden con mediciones BLE.
abstract class DeviceControls {
  Stream<HandSenseConnectionState> get connectionStates;
  Stream<DeviceTelemetry> get telemetry;
  HandSenseConnectionState get connectionState;
  Future<void> connect();
  Future<void> disconnect();
  Future<bool> ping();
  Future<bool> resetDeviceSession();
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

/// Resumen derivado exclusivamente de sesiones terminadas con procedencia
/// conocida. Las muestras no evaluables quedan fuera de las tasas.
class ActivitySummary {
  ActivitySummary._(this.sessions, this.recentSessions);

  factory ActivitySummary.fromSessions(
    Iterable<SessionRecord> records, {
    required bool demo,
  }) {
    final matching = records.where((record) => record.isDemo == demo).toList()
      ..sort((a, b) => a.finishedAt.compareTo(b.finishedAt));
    final recent = matching.length <= 7
        ? matching
        : matching.sublist(matching.length - 7);
    return ActivitySummary._(
      List.unmodifiable(matching),
      List.unmodifiable(recent),
    );
  }

  final List<SessionRecord> sessions;
  final List<SessionRecord> recentSessions;

  int get sessionCount => sessions.length;
  int get complete => sessions.fold(0, (total, item) => total + item.complete);
  int get incomplete =>
      sessions.fold(0, (total, item) => total + item.incomplete);
  int get evaluable => complete + incomplete;
  double? get completionPercentage =>
      evaluable == 0 ? null : complete * 100 / evaluable;
  SessionRecord? get latest => sessions.isEmpty ? null : sessions.last;
}
