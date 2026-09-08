import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../domain/repositories/order_repository.dart';
import '../models/requests/order_request.dart';
import '../models/responses/order_response.dart';

class OrderRemoteDataSource {
  final Dio _dio;
  OrderRemoteDataSource(this._dio);

  Future<List<OrderResponseDto>> getOrders() async {
    final res = await _dio.get(ApiEndpoints.orders);
    final raw = (res.data['data'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(OrderResponseDto.fromJson)
        .toList();
  }

  Future<OrderResponseDto> getOrderDetail(String id) async {
    final res = await _dio.get(
      ApiEndpoints.orderDetail.replaceAll('{id}', id),
    );
    return OrderResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<OrderResponseDto> createOrder({
    required String customerName,
    required String phoneNumber,
    required String addressLine,
    String? note,
    required List<OrderItemInput> items,
    String paymentMethod = 'cod',
    double shippingFee = 0,
    double discountAmount = 0,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.orders,
      data: CreateOrderRequestDto(
        customerName: customerName,
        phoneNumber: phoneNumber,
        addressLine: addressLine,
        note: note,
        items: items
            .map((e) => OrderItemRequestDto(
                  treeId: e.treeId,
                  quantity: e.quantity,
                ))
            .toList(),
        paymentMethod: paymentMethod,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
      ).toJson(),
    );
    return OrderResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}