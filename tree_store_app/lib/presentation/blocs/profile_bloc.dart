import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import '../../domain/usecases/profile/update_profile_usecase.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileLoad extends ProfileEvent {
  const ProfileLoad();
  @override
  List<Object?> get props => [];
}

class ProfileUpdate extends ProfileEvent {
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  const ProfileUpdate({this.fullName, this.phoneNumber, this.avatarUrl});
  @override
  List<Object?> get props => [fullName, phoneNumber, avatarUrl];
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

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
  @override
  List<Object?> get props => [];
}

class ProfileUpdated extends ProfileState {
  final User user;
  const ProfileUpdated(this.user);
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
  final UpdateProfileUsecase _updateProfile;

  ProfileBloc({required GetProfileUsecase getProfile, required UpdateProfileUsecase updateProfile})
      : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileUpdate>(_onUpdate);
  }

  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    debugPrint('[DEBUG] ProfileBloc._onLoad called');
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) {
        debugPrint('[DEBUG] ProfileBloc._onLoad failed: ${f.message}');
        emit(ProfileError(f.message));
      },
      (user) {
        debugPrint('[DEBUG] ProfileBloc._onLoad success, userId: ${user.id}');
        emit(ProfileLoaded(user));
      },
    );
  }

  Future<void> _onUpdate(ProfileUpdate event, Emitter<ProfileState> emit) async {
    debugPrint('[DEBUG] ProfileBloc._onUpdate called, fullName: ${event.fullName}');
    emit(const ProfileUpdating());
    final result = await _updateProfile(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      avatarUrl: event.avatarUrl,
    );
    result.fold(
      (f) {
        debugPrint('[DEBUG] ProfileBloc._onUpdate failed: ${f.message}');
        emit(ProfileError(f.message));
      },
      (user) {
        debugPrint('[DEBUG] ProfileBloc._onUpdate success, userId: ${user.id}');
        emit(ProfileUpdated(user));
      },
    );
  }
}