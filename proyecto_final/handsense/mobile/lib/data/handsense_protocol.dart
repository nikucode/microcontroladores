import 'dart:convert';

import 'attempt.dart';

/// Contrato GATT v1 de HandSense. Estos UUID deben copiarse sin cambios al
/// firmware ESP32. Los mensajes se mantienen bajo 20 bytes para funcionar con
/// el MTU BLE mínimo sin fragmentación.
abstract final class HandSenseGatt {
  static const deviceName = 'HandSense';
  static const service = '6c7a0001-8e2d-4f91-a6b5-3d3f7a120001';
  static const events = '6c7a0002-8e2d-4f91-a6b5-3d3f7a120001';
  static const control = '6c7a0003-8e2d-4f91-a6b5-3d3f7a120001';

  static List<int> command(String name) => utf8.encode('HS1,C,$name');
}

sealed class HandSenseFrame {
  const HandSenseFrame();
}

class AttemptFrame extends HandSenseFrame {
  const AttemptFrame(this.sequence, this.outcome);
  final int sequence;
  final Outcome outcome;
}

class AcknowledgementFrame extends HandSenseFrame {
  const AcknowledgementFrame(this.command, this.ok);
  final String command;
  final bool ok;
}

/// Eventos: `HS1,E,<secuencia>,<codigo>`.
/// C=completa, NC=sin contacto, NF=sin flexión, NR=sin liberación,
/// U=no evaluable. Confirmaciones: `HS1,A,<comando>,OK|ERR`.
HandSenseFrame? parseHandSenseFrame(List<int> bytes) {
  final text = utf8.decode(bytes, allowMalformed: true).trim();
  final fields = text.split(',');
  if (fields.length < 4 || fields.first != 'HS1') return null;

  if (fields[1] == 'E') {
    final sequence = int.tryParse(fields[2]);
    final outcome = switch (fields[3]) {
      'C' => Outcome.complete,
      'NC' => Outcome.noContact,
      'NF' => Outcome.noFlexion,
      'NR' => Outcome.noRelease,
      'U' => Outcome.unreliable,
      _ => null,
    };
    if (sequence == null || sequence < 0 || outcome == null) return null;
    return AttemptFrame(sequence, outcome);
  }

  if (fields[1] == 'A') {
    return AcknowledgementFrame(fields[2], fields[3] == 'OK');
  }
  return null;
}
