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
    // Backend returns list at root
    final raw = res.data is List ? (res.data as List) : const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(OrderResponseDto.fromJson)
        .toList();
  }

  Future<OrderResponseDto> getOrderDetail(String id) async {
    final res = await _dio.get(
      ApiEndpoints.orderDetail.replaceAll('{id}', id),
    );
    // Backend returns object at root
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid order detail response');
    }
    return OrderResponseDto.fromJson(data);
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
    // Backend returns object at root
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid order create response');
    }
    return OrderResponseDto.fromJson(data);
  }
}