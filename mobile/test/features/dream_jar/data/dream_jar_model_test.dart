import 'package:cupid_mobile/features/dream_jar/data/dream_jar.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _jarJson({
  Object? targetAmount = 50000000,
  Object? currentAmount = 12000000,
  Object? deadline,
  Object? status = 'active',
  Object? progress = 24,
}) => <String, dynamic>{
  'id': 'jar-1',
  'name': 'Trip to Da Lat',
  'targetAmount': targetAmount,
  'currentAmount': currentAmount,
  'deadline': deadline,
  'currency': 'VND',
  'status': status,
  'progress': progress,
  'createdAt': '2026-01-01T00:00:00.000Z',
};

void main() {
  group('DreamJar.fromJson', () {
    test('string and numeric decimal amounts decode identically', () {
      final fromString = DreamJar.fromJson(
        _jarJson(targetAmount: '50000000.00', currentAmount: '12000000.00'),
      );
      final fromNumber = DreamJar.fromJson(
        _jarJson(targetAmount: 50000000, currentAmount: 12000000),
      );

      expect(fromString.targetAmount, fromNumber.targetAmount);
      expect(fromString.currentAmount, fromNumber.currentAmount);
      expect(fromString.targetAmount, 50000000);
      expect(fromString.currentAmount, 12000000);
    });

    test('a null amount defaults to 0', () {
      final jar = DreamJar.fromJson(
        _jarJson(targetAmount: null, currentAmount: null),
      );

      expect(jar.targetAmount, 0);
      expect(jar.currentAmount, 0);
    });

    test('a null deadline decodes to null', () {
      final jar = DreamJar.fromJson(_jarJson(deadline: null));

      expect(jar.deadline, isNull);
    });

    test('a non-null deadline decodes to a DateTime', () {
      final jar = DreamJar.fromJson(
        _jarJson(deadline: '2026-12-31T00:00:00.000Z'),
      );

      expect(jar.deadline, DateTime.parse('2026-12-31T00:00:00.000Z'));
    });

    test('an unrecognized status falls back to active', () {
      final jar = DreamJar.fromJson(_jarJson(status: 'unknown_future_status'));

      expect(jar.status, DreamJarStatus.active);
    });

    for (final status in DreamJarStatus.values) {
      test('decodes the ${status.name} status from its lowercase wire value', () {
        final jar = DreamJar.fromJson(_jarJson(status: status.name));

        expect(jar.status, status);
      });
    }
  });

  group('Contribution.fromJson', () {
    Map<String, dynamic> contributionJson({Object? amount = 200000}) =>
        <String, dynamic>{
          'id': 'contribution-1',
          'dreamJarId': 'jar-1',
          'userId': 'user-1',
          'amount': amount,
          'note': null,
          'createdAt': '2026-01-01T00:00:00.000Z',
        };

    test('string and numeric decimal amounts decode identically', () {
      final fromString = Contribution.fromJson(
        contributionJson(amount: '200000.00'),
      );
      final fromNumber = Contribution.fromJson(contributionJson(amount: 200000));

      expect(fromString.amount, fromNumber.amount);
      expect(fromString.amount, 200000);
    });

    test('a null amount defaults to 0', () {
      final contribution = Contribution.fromJson(contributionJson(amount: null));

      expect(contribution.amount, 0);
    });
  });

  group('DreamJar.progressPercent', () {
    int progressFor({
      Object? progress,
      Object? targetAmount = 50000000,
      Object? currentAmount = 12000000,
    }) => DreamJar.fromJson(
      _jarJson(
        progress: progress,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
      ),
    ).progressPercent;

    test('prefers the server-provided progress when present', () {
      expect(progressFor(progress: 24), 24);
    });

    test('computes from amounts when progress is absent', () {
      expect(
        progressFor(progress: null, targetAmount: 50, currentAmount: 25),
        50,
      );
    });

    test('returns 0 for a zero target amount', () {
      expect(progressFor(progress: null, targetAmount: 0, currentAmount: 10), 0);
    });

    test('returns 0 for a zero current amount', () {
      expect(progressFor(progress: null, targetAmount: 100, currentAmount: 0), 0);
    });

    test('clamps to 100 when current exceeds target', () {
      expect(
        progressFor(progress: null, targetAmount: 100, currentAmount: 250),
        100,
      );
    });

    test('clamps a server progress above 100', () {
      expect(progressFor(progress: 250), 100);
    });
  });
}
