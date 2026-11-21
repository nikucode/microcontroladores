import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:handsense/data/attempt.dart';
import 'package:handsense/data/handsense_protocol.dart';

void main() {
  test('decodifica los cinco resultados sin confundir categorías', () {
    final expected = <String, Outcome>{
      'C': Outcome.complete,
      'NC': Outcome.noContact,
      'NF': Outcome.noFlexion,
      'NR': Outcome.noRelease,
      'U': Outcome.unreliable,
    };

    for (final entry in expected.entries) {
      final frame = parseHandSenseFrame(utf8.encode('HS1,E,17,${entry.key}'));
      expect(frame, isA<AttemptFrame>());
      final attempt = frame! as AttemptFrame;
      expect(attempt.sequence, 17);
      expect(attempt.outcome, entry.value);
    }
  });

  test('rechaza versiones, códigos y secuencias inválidas', () {
    expect(parseHandSenseFrame(utf8.encode('HS2,E,1,C')), isNull);
    expect(parseHandSenseFrame(utf8.encode('HS1,E,-1,C')), isNull);
    expect(parseHandSenseFrame(utf8.encode('HS1,E,1,OTRO')), isNull);
    expect(parseHandSenseFrame(const [0xff, 0x00]), isNull);
  });

  test('distingue confirmación PING y mantiene comandos bajo 20 bytes', () {
    final frame = parseHandSenseFrame(utf8.encode('HS1,A,PING,OK'));
    expect(frame, isA<AcknowledgementFrame>());
    final acknowledgement = frame! as AcknowledgementFrame;
    expect(acknowledgement.command, 'PING');
    expect(acknowledgement.ok, isTrue);
    expect(HandSenseGatt.command('PING').length, lessThanOrEqualTo(20));
  });
}
