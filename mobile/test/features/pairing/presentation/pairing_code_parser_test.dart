import 'package:cupid_mobile/features/pairing/presentation/pairing_code_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePairingCode accepts', () {
    const Map<String, String> accepted = <String, String>{
      'ABC123': 'ABC123',
      'abc123': 'ABC123',
      '  ABC123  ': 'ABC123',
      '\nABC123\t': 'ABC123',
      'ABC-123': 'ABC123',
      'abc 123': 'ABC123',
      'https://cupid.app/join/ABC123': 'ABC123',
      'https://cupid.app/join/abc123': 'ABC123',
      'cupid://ABC123': 'ABC123',
      'cupid://pair/ABC123': 'ABC123',
      '123456': '123456',
      'ABCDEF': 'ABCDEF',
    };

    accepted.forEach((String raw, String expected) {
      test('"$raw" -> $expected', () {
        expect(parsePairingCode(raw), expected);
      });
    });
  });

  group('parsePairingCode rejects', () {
    const List<String> rejected = <String>[
      '',
      '   ',
      'ABC12',
      'ABC1234',
      '-----',
      '!!!!!!',
      'https://cupid.app/join/',
      'https://cupid.app/',
      'https://cupid.app/join/ABC12',
      'https://cupid.app/join/ABC1234',
      'WIFI:S:HomeNet;T:WPA2;',
      'BEGIN:VCARD',
    ];

    for (final String raw in rejected) {
      test('"$raw" -> null', () {
        expect(parsePairingCode(raw), isNull);
      });
    }
  });

  test('a bare URL never degrades into the scheme prefix', () {
    // `_pasteCode`'s truncate-to-first-six rule would yield `HTTPS:` here,
    // which is a real-looking code and would reach the backend.
    expect(parsePairingCode('https://cupid.app/join/'), isNull);
    expect(parsePairingCode('https://example.com'), isNull);
  });

  test('the accepted length matches the manual entry field', () {
    expect(pairingCodeLength, 6);
  });
}
