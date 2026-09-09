import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
  @override
  List<Object?> get props => [];
}

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileState {
  final User user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase _getProfile;

  ProfileBloc({required GetProfileUsecase getProfile})
      : _getProfile = getProfile,
        super(const ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
  }

  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}