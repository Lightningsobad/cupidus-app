import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingChain.next', () {
    test('follows the corrected navigation graph forward order', () {
      const Map<OnboardingNode, OnboardingNode> expected =
          <OnboardingNode, OnboardingNode>{
            OnboardingNode.register: OnboardingNode.otp,
            OnboardingNode.otp: OnboardingNode.permissions,
            OnboardingNode.permissions: OnboardingNode.profileSetup,
            OnboardingNode.profileSetup: OnboardingNode.pairingChoice,
            OnboardingNode.invite: OnboardingNode.waiting,
            OnboardingNode.waiting: OnboardingNode.paired,
            OnboardingNode.joinCode: OnboardingNode.paired,
            OnboardingNode.paired: OnboardingNode.loveContract,
            OnboardingNode.loveContract: OnboardingNode.vow,
            OnboardingNode.vow: OnboardingNode.home,
          };

      for (final MapEntry<OnboardingNode, OnboardingNode> edge
          in expected.entries) {
        expect(
          OnboardingChain.next(edge.key),
          edge.value,
          reason: '${edge.key.name} must advance to ${edge.value.name}',
        );
      }
    });

    test(
      'registration chain reaches pairingChoice without skipping a step',
      () {
        final List<OnboardingNode> walked = <OnboardingNode>[
          OnboardingNode.register,
        ];
        OnboardingNode? cursor = OnboardingNode.register;
        while ((cursor = OnboardingChain.next(cursor!)) != null) {
          walked.add(cursor!);
        }

        expect(walked, <OnboardingNode>[
          OnboardingNode.register,
          OnboardingNode.otp,
          OnboardingNode.permissions,
          OnboardingNode.profileSetup,
          OnboardingNode.pairingChoice,
        ]);
      },
    );

    test('pairing tail runs paired -> loveContract -> vow -> home', () {
      final List<OnboardingNode> walked = <OnboardingNode>[
        OnboardingNode.paired,
      ];
      OnboardingNode? cursor = OnboardingNode.paired;
      while ((cursor = OnboardingChain.next(cursor!)) != null) {
        walked.add(cursor!);
      }

      expect(walked, <OnboardingNode>[
        OnboardingNode.paired,
        OnboardingNode.loveContract,
        OnboardingNode.vow,
        OnboardingNode.home,
      ]);
    });

    test('branching and terminal nodes have no single successor', () {
      for (final OnboardingNode node in <OnboardingNode>[
        OnboardingNode.welcome,
        OnboardingNode.login,
        OnboardingNode.pairingChoice,
        OnboardingNode.forgotPassword,
        OnboardingNode.home,
      ]) {
        expect(
          OnboardingChain.next(node),
          isNull,
          reason: '${node.name} must let the caller pick',
        );
      }
    });
  });

  group('OnboardingChain.isChromeless', () {
    test('is true for every node except home', () {
      for (final OnboardingNode node in OnboardingNode.values) {
        expect(
          OnboardingChain.isChromeless(node),
          node != OnboardingNode.home,
          reason: '${node.name} chrome membership',
        );
      }
    });
  });
}
