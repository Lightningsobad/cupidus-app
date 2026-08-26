import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

sealed class OtpState {
  const OtpState({
    required this.email,
    this.resendSeconds = 0,
  });

  final String email;
  final int resendSeconds;
}

class OtpInitial extends OtpState {
  const OtpInitial({
    required super.email,
    super.resendSeconds = 60,
  });
}

class OtpInProgress extends OtpState {
  const OtpInProgress({
    required super.email,
    required super.resendSeconds,
  });
}

class OtpSuccess extends OtpState {
  const OtpSuccess({
    required super.email,
  }) : super(resendSeconds: 0);
}

class OtpFailed extends OtpState {
  const OtpFailed({
    required super.email,
    required super.resendSeconds,
    required this.failure,
  });

  final Object failure;
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required AuthRepository repository,
    required String email,
  })  : _repository = repository,
        super(OtpInitial(email: email)) {
    _startCooldown();
  }

  final AuthRepository _repository;
  Timer? _cooldownTimer;

  void _startCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    int current = seconds;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      current -= 1;
      if (current <= 0) {
        timer.cancel();
        if (state is! OtpSuccess) {
          emit(OtpInitial(email: state.email, resendSeconds: 0));
        }
      } else {
        if (state is OtpInProgress) {
          emit(OtpInProgress(email: state.email, resendSeconds: current));
        } else if (state is OtpFailed) {
          emit(OtpFailed(
            email: state.email,
            resendSeconds: current,
            failure: (state as OtpFailed).failure,
          ));
        } else if (state is! OtpSuccess) {
          emit(OtpInitial(email: state.email, resendSeconds: current));
        }
      }
    });
  }

  Future<void> verifyCode(String code) async {
    if (code.trim().length != 6 || state is OtpInProgress) return;

    emit(OtpInProgress(
      email: state.email,
      resendSeconds: state.resendSeconds,
    ));

    try {
      await _repository.verifyOtp(email: state.email, code: code);
      if (!isClosed) {
        _cooldownTimer?.cancel();
        emit(OtpSuccess(email: state.email));
      }
    } catch (failure) {
      if (!isClosed) {
        emit(OtpFailed(
          email: state.email,
          resendSeconds: state.resendSeconds,
          failure: failure,
        ));
      }
    }
  }

  Future<void> resendCode() async {
    if (state.resendSeconds > 0 || state is OtpInProgress) return;

    try {
      await _repository.resendOtp(email: state.email);
      if (!isClosed) {
        emit(OtpInitial(email: state.email, resendSeconds: 60));
        _startCooldown(60);
      }
    } catch (failure) {
      if (!isClosed) {
        emit(OtpFailed(
          email: state.email,
          resendSeconds: 0,
          failure: failure,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}
