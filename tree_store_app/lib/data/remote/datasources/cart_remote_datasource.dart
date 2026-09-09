import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/cart_response.dart';

class CartRemoteDataSource {
  final Dio _dio;
  CartRemoteDataSource(this._dio);

  Future<List<CartItemResponseDto>> getCart() async {
    final res = await _dio.get(ApiEndpoints.cart);
    final raw = (res.data as List?) ?? const [];
    return raw.whereType<Map<String, dynamic>>().map(CartItemResponseDto.fromJson).toList();
  }

  Future<void> addToCart({required String treeId, int quantity = 1, String? note}) async {
    await _dio.post(
      ApiEndpoints.cart,
      data: {
        'treeId': treeId,
        'quantity': quantity,
        if (note != null) 'note': note,
      },
    );
  }

  Future<void> removeFromCart(String id) async {
    await _dio.delete(ApiEndpoints.cartItem.replaceAll('{id}', id));
  }
}