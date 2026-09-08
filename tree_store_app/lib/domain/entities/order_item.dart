import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String? productId;
  final String productNameSnapshot;
  final double priceSnapshot;
  final int quantity;
  final double lineTotal;
  final String? imageUrlSnapshot;
  final Map<String, dynamic> optionsSnapshot;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productNameSnapshot,
    required this.priceSnapshot,
    this.quantity = 1,
    required this.lineTotal,
    this.imageUrlSnapshot,
    this.optionsSnapshot = const {},
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productNameSnapshot,
        priceSnapshot,
        quantity,
        lineTotal,
        imageUrlSnapshot,
        optionsSnapshot,
      ];
}