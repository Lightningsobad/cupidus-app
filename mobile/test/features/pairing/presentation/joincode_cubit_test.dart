import 'dart:async';

import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_failure.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoincodeCubit', () {
    test('starts in JoincodeIdle', () {
      final cubit = JoincodeCubit(acceptInvitation: (_) async {});
      addTearDown(cubit.close);

      expect(cubit.state, isA<JoincodeIdle>());
    });

    test(
      'emits JoincodeInProgress immediately, then JoincodeSuccess',
      () async {
        String? sentCode;
        final completer = Completer<void>();
        final cubit = JoincodeCubit(
          acceptInvitation: (code) {
            sentCode = code;
            return completer.future;
          },
        );
        addTearDown(cubit.close);

        final submitFuture = cubit.submit('3F9A2B');
        expect(cubit.state, isA<JoincodeInProgress>());

        completer.complete();
        await submitFuture;

        expect(sentCode, '3F9A2B');
        expect(cubit.state, isA<JoincodeSuccess>());
      },
    );

    test('emits Failed with the thrown PairingFailure and re-enables', () async {
      final cubit = JoincodeCubit(
        acceptInvitation: (_) async =>
            throw const InvalidOrExpiredCodeFailure(),
      );
      addTearDown(cubit.close);

      await cubit.submit('BADCOD');

      expect(cubit.state, isA<JoincodeFailed>());
      expect(
        (cubit.state as JoincodeFailed).failure,
        isA<InvalidOrExpiredCodeFailure>(),
      );
    });

    test('maps each of the three 409 cases distinctly', () async {
      Future<void> expectFailure(
        PairingFailure thrown,
        Matcher matcher,
      ) async {
        final cubit = JoincodeCubit(
          acceptInvitation: (_) async => throw thrown,
        );
        addTearDown(cubit.close);

        await cubit.submit('3F9A2B');

        expect((cubit.state as JoincodeFailed).failure, matcher);
      }

      await expectFailure(
        const AlreadyPairedFailure(),
        isA<AlreadyPairedFailure>(),
      );
      await expectFailure(const SelfInviteFailure(), isA<SelfInviteFailure>());
      await expectFailure(
        const InviterAlreadyPairedFailure(),
        isA<InviterAlreadyPairedFailure>(),
      );
    });

    test('an unmapped failure carries the underlying CupidApiFailure', () async {
      final cubit = JoincodeCubit(
        acceptInvitation: (_) async =>
            throw const UnmappedPairingFailure(UnexpectedFailure()),
      );
      addTearDown(cubit.close);

      await cubit.submit('3F9A2B');

      final failure = cubit.state as JoincodeFailed;
      expect(failure.failure, isA<UnmappedPairingFailure>());
      expect(
        (failure.failure as UnmappedPairingFailure).cause,
        isA<UnexpectedFailure>(),
      );
    });
  });
}
