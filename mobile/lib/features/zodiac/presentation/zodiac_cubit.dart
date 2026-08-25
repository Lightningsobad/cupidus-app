import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/cupid_api_failure.dart';
import '../data/zodiac_repository.dart';
import '../domain/zodiac_red_flag.dart';
import 'zodiac_state.dart';

/// Drives the `zodiac` screen. One fetch per open, plus an explicit retry from
/// the error state. No refresh-on-resume and no shuffle/regenerate affordance:
/// content is fixed for a `contentDate`, so a re-fetch expecting different
/// content would be a lie (`architecture/contract-summary.md` §6).
class ZodiacCubit extends Cubit<ZodiacState> {
  ZodiacCubit({required this._repository}) : super(const ZodiacLoading());

  final ZodiacRepository _repository;

  Future<void> load() async {
    emit(const ZodiacLoading());
    try {
      final today = await _repository.fetchToday();
      if (isClosed) return;
      emit(switch (today) {
        ZodiacRedFlagReady() => ZodiacReady(today),
        ZodiacRedFlagIncompleteProfile() => ZodiacIncompleteProfile(today),
      });
    } on CupidApiFailure catch (failure) {
      if (!isClosed) emit(ZodiacError(failure));
    }
  }
}
