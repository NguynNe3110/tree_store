import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String? userId;
  final String? label;
  final String receiverName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String district;
  final String? ward;
  final String? postalCode;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Address({
    required this.id,
    this.userId,
    this.label,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.district,
    this.ward,
    this.postalCode,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullAddress => '$addressLine, $ward, $district, $city';

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        receiverName,
        phoneNumber,
        addressLine,
        city,
        district,
        ward,
        postalCode,
        isDefault,
        createdAt,
        updatedAt,
      ];
}