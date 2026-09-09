import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/auth/send_otp_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();
}

class OtpSend extends OtpEvent {
  final String email;
  final String purpose;
  const OtpSend({required this.email, required this.purpose});
  @override
  List<Object?> get props => [email, purpose];
}

class OtpVerify extends OtpEvent {
  final String email;
  final String code;
  final String purpose;
  const OtpVerify({required this.email, required this.code, required this.purpose});
  @override
  List<Object?> get props => [email, code, purpose];
}

class OtpTick extends OtpEvent {
  const OtpTick();
  @override
  List<Object?> get props => [];
}

class OtpResend extends OtpEvent {
  final String email;
  final String purpose;
  const OtpResend({required this.email, required this.purpose});
  @override
  List<Object?> get props => [email, purpose];
}

abstract class OtpState extends Equatable {
  const OtpState();
}

class OtpInitial extends OtpState {
  const OtpInitial();
  @override
  List<Object?> get props => [];
}

class OtpSending extends OtpState {
  const OtpSending();
  @override
  List<Object?> get props => [];
}

class OtpSent extends OtpState {
  final int remainingSeconds;
  const OtpSent({this.remainingSeconds = 60});
  @override
  List<Object?> get props => [remainingSeconds];
}

class OtpVerifying extends OtpState {
  const OtpVerifying();
  @override
  List<Object?> get props => [];
}

class OtpVerified extends OtpState {
  const OtpVerified();
  @override
  List<Object?> get props => [];
}

class OtpError extends OtpState {
  final String message;
  const OtpError(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final SendOtpUsecase _sendOtp;
  final VerifyOtpUsecase _verifyOtp;
  Timer? _timer;

  OtpBloc({required SendOtpUsecase sendOtp, required VerifyOtpUsecase verifyOtp})
      : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        super(const OtpInitial()) {
    on<OtpSend>(_onSend);
    on<OtpVerify>(_onVerify);
    on<OtpTick>(_onTick);
    on<OtpResend>(_onResend);
  }

  Future<void> _onSend(OtpSend event, Emitter<OtpState> emit) async {
    emit(const OtpSending());
    final result = await _sendOtp(email: event.email, purpose: event.purpose);
    result.fold(
      (f) => emit(OtpError(f.message)),
      (_) {
        emit(const OtpSent(remainingSeconds: 60));
        _startTimer();
      },
    );
  }

  Future<void> _onVerify(OtpVerify event, Emitter<OtpState> emit) async {
    emit(const OtpVerifying());
    final result = await _verifyOtp(email: event.email, code: event.code, purpose: event.purpose);
    result.fold(
      (f) => emit(OtpError(f.message)),
      (verified) {
        if (verified) {
          _stopTimer();
          emit(const OtpVerified());
        } else {
          emit(const OtpError('OTP không hợp lệ hoặc đã hết hạn'));
        }
      },
    );
  }

  void _onTick(OtpTick event, Emitter<OtpState> emit) {
    final currentState = state;
    if (currentState is OtpSent) {
      if (currentState.remainingSeconds <= 1) {
        _stopTimer();
        emit(const OtpSent(remainingSeconds: 0));
      } else {
        emit(OtpSent(remainingSeconds: currentState.remainingSeconds - 1));
      }
    }
  }

  Future<void> _onResend(OtpResend event, Emitter<OtpState> emit) async {
    emit(const OtpSending());
    final result = await _sendOtp(email: event.email, purpose: event.purpose);
    result.fold(
      (f) => emit(OtpError(f.message)),
      (_) {
        emit(const OtpSent(remainingSeconds: 60));
        _startTimer();
      },
    );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const OtpTick());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
