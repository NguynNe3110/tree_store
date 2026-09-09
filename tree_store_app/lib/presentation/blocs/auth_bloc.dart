import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/network/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthCheckToken extends AuthEvent {
  const AuthCheckToken();
  @override
  List<Object?> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthLogin(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthRegister extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  const AuthRegister({required this.fullName, required this.email, required this.password, this.phoneNumber});
  @override
  List<Object?> get props => [fullName, email, password, phoneNumber];
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
  @override
  List<Object?> get props => [];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _login;
  final RegisterUsecase _register;
  final LogoutUsecase _logout;
  final GetProfileUsecase _getProfile;
  final TokenStorage _tokenStorage;

  AuthBloc({
    required LoginUsecase login,
    required RegisterUsecase register,
    required LogoutUsecase logout,
    required GetProfileUsecase getProfile,
    required TokenStorage tokenStorage,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _getProfile = getProfile,
        _tokenStorage = tokenStorage,
        super(const AuthInitial()) {
    on<AuthCheckToken>(_onCheckToken);
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckToken(AuthCheckToken event, Emitter<AuthState> emit) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final result = await _getProfile();
      result.fold(
        (_) => emit(const AuthUnauthenticated()),
        (user) => emit(AuthAuthenticated(user)),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _login(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _register(RegisterParams(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _logout();
    emit(const AuthUnauthenticated());
  }
}