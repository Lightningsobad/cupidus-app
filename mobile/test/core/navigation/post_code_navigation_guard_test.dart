// INV-1 guard (`architecture/solution.md` §4): Fingerprint Vow is never the
// successor of `invite` or `joinCode`. It stays reachable only on the
// post-pairing tail `paired -> loveContract -> vow -> home`, which
// `chain_tail_edges_test.dart` owns and this suite must not duplicate.
import 'dart:io';

import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Paths are relative to `mobile/`, the directory `flutter test` runs from
/// (same convention as `test/design_system/no_fork_guard_test.dart`).
const List<String> _postCodeScreenSources = <String>[
  'lib/features/pairing/presentation/screens/invite_screen.dart',
  'lib/features/pairing/presentation/screens/joincode_screen.dart',
];

const List<String> _forbiddenVowReferences = <String>[
  'VowScreen',
  'OnboardingNode.vow',
  'features/vow/',
];

void main() {
  group('post-code forward edges', () {
    test('AC1/AC2: invite advances to waiting, never vow', () {
      expect(
        OnboardingChain.next(OnboardingNode.invite),
        OnboardingNode.waiting,
      );
      expect(
        OnboardingChain.next(OnboardingNode.invite),
        isNot(OnboardingNode.vow),
      );
    });

    test('AC3: joinCode advances to paired, never vow', () {
      // Assumption A2 (`architecture/solution.md` §3): ADR-4 keeps
      // `acceptInvitation(code)` synchronous for the invitee, so this branch
      // has no `waiting` step and resolves straight to `paired`. AC3's binding
      // content — "not Fingerprint Vow" — is what the second expectation pins.
      expect(
        OnboardingChain.next(OnboardingNode.joinCode),
        OnboardingNode.paired,
      );
      expect(
        OnboardingChain.next(OnboardingNode.joinCode),
        isNot(OnboardingNode.vow),
      );
    });

    test('pairingChoice is a branching node with no forward successor', () {
      expect(OnboardingChain.next(OnboardingNode.pairingChoice), isNull);
    });
  });

  test('AC7: no vow reference reaches the invite/join-code source', () {
    // The only check that catches a future Continue CTA wired straight to vow
    // with `Navigator.push`, which a chain-level assertion cannot see.
    final List<String> violations = <String>[];

    for (final String path in _postCodeScreenSources) {
      final File file = File(path);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'guarded post-code source is missing: $path',
      );

      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        for (final String pattern in _forbiddenVowReferences) {
          if (lines[i].contains(pattern)) {
            violations.add('$path:${i + 1}: forbidden reference "$pattern"');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'The immediate post-code destination must be `waiting` (invite) or '
          '`paired` (join-code); vow belongs to the post-pairing tail only '
          '(REQ-009 Locked Navigation Decision 2, INV-1):\n'
          '${violations.join('\n')}',
    );
  });
}
