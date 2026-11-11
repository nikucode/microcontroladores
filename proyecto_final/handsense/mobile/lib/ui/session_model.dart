import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/attempt.dart';

class SessionModel extends ChangeNotifier {
  SessionModel(this.source) {
    _subscription = source.events.listen((attempt) {
      _attempts.add(attempt);
      notifyListeners();
    });
  }
  final AttemptSource source;
  late final StreamSubscription<Attempt> _subscription;
  final List<Attempt> _attempts = [];
  final List<SessionRecord> _sessions = [];
  List<Attempt> get attempts => List.unmodifiable(_attempts);
  List<SessionRecord> get sessions => List.unmodifiable(_sessions.reversed);
  bool get canSimulate => source is DemoControls;
  int get complete => attempts.where((a) => a.complete).length;
  int get incomplete =>
      attempts.where((a) => a.evaluable && !a.complete).length;
  int get unreliable => attempts.where((a) => !a.evaluable).length;
  int get flexOnly => attempts.where((a) => a.flexCycle).length;
  void simulate(Outcome outcome) {
    if (source case final DemoControls controls) controls.simulate(outcome);
  }

  void finish() {
    if (_attempts.isEmpty) return;
    _sessions.add(
      SessionRecord(
        _sessions.length + 1,
        DateTime.now(),
        source.label,
        source.isDemo,
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
    _subscription.cancel();
    source.dispose();
    super.dispose();
  }
}
