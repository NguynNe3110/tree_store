import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, fullName, email, phoneNumber, avatarUrl, createdAt, updatedAt];
}