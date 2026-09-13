import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import '../../domain/usecases/profile/update_profile_usecase.dart';
import '../../domain/usecases/profile/upload_avatar_usecase.dart';

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

class ProfileUpdateAvatar extends ProfileEvent {
  final String filePath;
  const ProfileUpdateAvatar(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
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
  final UploadAvatarUsecase _uploadAvatar;

  ProfileBloc({
    required GetProfileUsecase getProfile,
    required UpdateProfileUsecase updateProfile,
    required UploadAvatarUsecase uploadAvatar,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _uploadAvatar = uploadAvatar,
        super(const ProfileInitial()) {
    on<ProfileLoad>(_onLoad);
    on<ProfileUpdate>(_onUpdate);
    on<ProfileUpdateAvatar>(_onUpdateAvatar);
  }

  Future<void> _onLoad(ProfileLoad event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdate(ProfileUpdate event, Emitter<ProfileState> emit) async {
    emit(const ProfileUpdating());
    final result = await _updateProfile(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      avatarUrl: event.avatarUrl,
    );
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (user) => emit(ProfileUpdated(user)),
    );
  }

  Future<void> _onUpdateAvatar(ProfileUpdateAvatar event, Emitter<ProfileState> emit) async {
    emit(const ProfileUpdating());
    final uploadResult = await _uploadAvatar(event.filePath);
    await uploadResult.fold(
      (f) async => emit(ProfileError(f.message)),
      (url) async {
        final updateResult = await _updateProfile(avatarUrl: url);
        updateResult.fold(
          (f) => emit(ProfileError(f.message)),
          (user) => emit(ProfileUpdated(user)),
        );
      },
    );
  }
}