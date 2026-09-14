import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';

class PaymentInitDto {
  final String paymentId;
  final int orderCode;
  final String checkoutUrl;

  const PaymentInitDto({
    required this.paymentId,
    required this.orderCode,
    required this.checkoutUrl,
  });

  factory PaymentInitDto.fromJson(Map<String, dynamic> json) => PaymentInitDto(
        paymentId: json['paymentId']?.toString() ?? '',
        orderCode: (json['orderCode'] as num?)?.toInt() ?? 0,
        checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      );
}

class PaymentRemoteDataSource {
  final Dio _dio;
  PaymentRemoteDataSource(this._dio);

  Future<PaymentInitDto> createPayment({
    required String orderId,
    required String provider,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.orderPayment.replaceAll('{id}', orderId),
      data: {'provider': provider},
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid payment response');
    }
    return PaymentInitDto.fromJson(data);
  }
}
