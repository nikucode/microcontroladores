import 'package:flutter/foundation.dart';

import '../data/attempt.dart';

class SessionModel extends ChangeNotifier {
  SessionModel(this.repository);
  final AttemptRepository repository;
  List<Attempt> get attempts => repository.attempts;
  int get complete => attempts.where((a) => a.complete).length;
  int get incomplete =>
      attempts.where((a) => a.evaluable && !a.complete).length;
  int get unreliable => attempts.where((a) => !a.evaluable).length;
  int get flexOnly => attempts.where((a) => a.flexCycle).length;
  void simulate(Outcome outcome) {
    repository.simulate(outcome);
    notifyListeners();
  }

  void reset() {
    repository.clear();
    notifyListeners();
  }
}
