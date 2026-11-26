import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/attempt.dart';

enum SessionRunState { idle, active, paused }

class SessionModel extends ChangeNotifier {
  SessionModel(AttemptSource source) : _source = source {
    _listenToSource();
  }

  AttemptSource _source;
  AttemptSource get source => _source;
  StreamSubscription<Attempt>? _subscription;
  StreamSubscription<HandSenseConnectionState>? _connectionSubscription;
  StreamSubscription<DeviceTelemetry>? _telemetrySubscription;
  DeviceTelemetry? _telemetry;
  DeviceTelemetry? get telemetry => _telemetry;
  Timer? _freshnessTimer;
  SessionRunState _runState = SessionRunState.idle;
  SessionRunState get runState => _runState;
  bool get sessionActive => _runState == SessionRunState.active;
  bool get sessionPaused => _runState == SessionRunState.paused;
  HandSenseConnectionState _connectionState = const HandSenseConnectionState(
    DeviceConnectionPhase.idle,
    'Modo demostración: no hay sensores físicos conectados.',
  );
  HandSenseConnectionState get connectionState => _connectionState;
  bool get isDemo => _source.isDemo;
  bool get isConnected => _connectionState.connected;
  bool get canConnect => _source is DeviceControls;
  String get sourceLabel => _source.label;
  Duration? get telemetryAge => _telemetry == null
      ? null
      : DateTime.now().difference(_telemetry!.receivedAt);
  bool get telemetryFresh =>
      telemetryAge != null && telemetryAge! <= const Duration(seconds: 2);
  bool get signalEvaluable =>
      telemetryFresh && _telemetry?.phase != GesturePhase.signalError;
  bool get readyForRealExercise =>
      !isDemo &&
      isConnected &&
      signalEvaluable &&
      _telemetry?.phase == GesturePhase.rest;

  void _listenToSource() {
    _subscription = _source.events.listen((attempt) {
      if (!sessionActive) return;
      if (!_source.isDemo && (!isConnected || !signalEvaluable)) return;
      _attempts.add(attempt);
      notifyListeners();
    });
    if (_source case final DeviceControls device) {
      _connectionState = device.connectionState;
      _connectionSubscription = device.connectionStates.listen((state) {
        _connectionState = state;
        if (!state.connected && sessionActive) {
          _runState = SessionRunState.paused;
        }
        notifyListeners();
      });
      _telemetrySubscription = device.telemetry.listen((reading) {
        _telemetry = reading;
        if (sessionActive && reading.phase == GesturePhase.signalError) {
          _runState = SessionRunState.paused;
        }
        notifyListeners();
      });
      _freshnessTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (sessionActive && !isDemo && !telemetryFresh) {
          _runState = SessionRunState.paused;
        }
        if (_telemetry != null) notifyListeners();
      });
    } else {
      _connectionState = const HandSenseConnectionState(
        DeviceConnectionPhase.idle,
        'Modo demostración: no hay sensores físicos conectados.',
      );
      _telemetry = null;
    }
  }

  final List<Attempt> _attempts = [];
  final List<SessionRecord> _sessions = [];
  List<Attempt> get attempts => List.unmodifiable(_attempts);
  List<SessionRecord> get sessions => List.unmodifiable(_sessions.reversed);
  bool get canSimulate => _source is DemoControls;
  int get complete => attempts.where((a) => a.complete).length;
  int get incomplete =>
      attempts.where((a) => a.evaluable && !a.complete).length;
  int get unreliable => attempts.where((a) => !a.evaluable).length;
  int get flexOnly => attempts.where((a) => a.flexCycle).length;
  void simulate(Outcome outcome) {
    if (sessionActive && _source is DemoControls) {
      (_source as DemoControls).simulate(outcome);
    }
  }

  void beginSession() {
    _runState = isDemo || readyForRealExercise
        ? SessionRunState.active
        : SessionRunState.paused;
    notifyListeners();
  }

  void pauseSession() {
    if (_runState == SessionRunState.active) {
      _runState = SessionRunState.paused;
      notifyListeners();
    }
  }

  bool resumeSession() {
    if (!isDemo && !readyForRealExercise) return false;
    _runState = SessionRunState.active;
    notifyListeners();
    return true;
  }

  Future<void> replaceSource(AttemptSource next) async {
    if (identical(next, _source)) return;
    if (_attempts.isNotEmpty) finish();
    await _subscription?.cancel();
    await _connectionSubscription?.cancel();
    await _telemetrySubscription?.cancel();
    _source.dispose();
    _source = next;
    _runState = SessionRunState.idle;
    _listenToSource();
    notifyListeners();
  }

  Future<void> connect() async {
    if (_source case final DeviceControls device) await device.connect();
  }

  Future<void> disconnect() async {
    if (_source case final DeviceControls device) await device.disconnect();
  }

  Future<bool> ping() async {
    if (_source case final DeviceControls device) return device.ping();
    return false;
  }

  Future<bool> resetDeviceSession() async {
    if (_source case final DeviceControls device) {
      final acknowledged = await device.resetDeviceSession();
      if (acknowledged) reset();
      return acknowledged;
    }
    return false;
  }

  SessionRecord? finish() {
    _runState = SessionRunState.idle;
    if (_attempts.isEmpty) {
      notifyListeners();
      return null;
    }
    final record = SessionRecord(
      _sessions.length + 1,
      DateTime.now(),
      _source.label,
      _source.isDemo,
      _attempts,
    );
    _sessions.add(record);
    _attempts.clear();
    notifyListeners();
    return record;
  }

  void reset() {
    _attempts.clear();
    _runState = SessionRunState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectionSubscription?.cancel();
    _telemetrySubscription?.cancel();
    _freshnessTimer?.cancel();
    _source.dispose();
    super.dispose();
  }
}
