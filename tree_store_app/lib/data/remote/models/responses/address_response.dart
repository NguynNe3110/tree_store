class AddressResponseDto {
  final String? id;
  final String? label;
  final String receiverName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String district;
  final String? ward;
  final String? postalCode;
  final bool isDefault;

  const AddressResponseDto({
    this.id,
    this.label,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.district,
    this.ward,
    this.postalCode,
    this.isDefault = false,
  });

  factory AddressResponseDto.fromJson(Map<String, dynamic> json) =>
      AddressResponseDto(
        id: json['id']?.toString(),
        label: json['label'] as String?,
        receiverName: json['receiverName']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        addressLine: json['addressLine']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        ward: json['ward'] as String?,
        postalCode: json['postalCode'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}