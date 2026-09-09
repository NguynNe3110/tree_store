import '../../domain/entities/address.dart';
import '../remote/models/responses/address_response.dart';

extension AddressResponseMapper on AddressResponseDto {
  Address toEntity() => Address(
        id: id ?? '',
        label: label,
        receiverName: receiverName,
        phoneNumber: phoneNumber,
        addressLine: addressLine,
        city: city,
        district: district,
        ward: ward,
        postalCode: postalCode,
        isDefault: isDefault,
      );
}