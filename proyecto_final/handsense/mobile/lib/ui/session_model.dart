import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/attempt.dart';

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
  HandSenseConnectionState _connectionState = const HandSenseConnectionState(
    DeviceConnectionPhase.idle,
    'Modo demostración: no hay sensores físicos conectados.',
  );
  HandSenseConnectionState get connectionState => _connectionState;
  bool get isDemo => _source.isDemo;
  bool get isConnected => _connectionState.connected;
  bool get canConnect => _source is DeviceControls;
  String get sourceLabel => _source.label;

  void _listenToSource() {
    _subscription = _source.events.listen((attempt) {
      _attempts.add(attempt);
      notifyListeners();
    });
    if (_source case final DeviceControls device) {
      _connectionState = device.connectionState;
      _connectionSubscription = device.connectionStates.listen((state) {
        _connectionState = state;
        if (!state.connected) _telemetry = null;
        notifyListeners();
      });
      _telemetrySubscription = device.telemetry.listen((reading) {
        _telemetry = reading;
        notifyListeners();
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
    if (_source case final DemoControls controls) controls.simulate(outcome);
  }

  Future<void> replaceSource(AttemptSource next) async {
    if (identical(next, _source)) return;
    if (_attempts.isNotEmpty) finish();
    await _subscription?.cancel();
    await _connectionSubscription?.cancel();
    await _telemetrySubscription?.cancel();
    _source.dispose();
    _source = next;
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

  void finish() {
    if (_attempts.isEmpty) return;
    _sessions.add(
      SessionRecord(
        _sessions.length + 1,
        DateTime.now(),
        _source.label,
        _source.isDemo,
        _attempts,
      ),
    );
    _attempts.clear();
    notifyListeners();
  }

  void reset() {
    _attempts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectionSubscription?.cancel();
    _telemetrySubscription?.cancel();
    _source.dispose();
    super.dispose();
  }
}
