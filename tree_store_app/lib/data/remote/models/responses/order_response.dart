class OrderResponseDto {
  final String id;
  final String? userId;
  final String customerName;
  final String phoneNumber;
  final String? addressLine;
  final String? note;
  final String status;
  final String paymentStatus;
  final double subtotalPrice;
  final double discountAmount;
  final double shippingFee;
  final double totalPrice;
  final List<OrderItemResponseDto> items;
  final String? createdAt;
  final String? updatedAt;

  const OrderResponseDto({
    required this.id,
    this.userId,
    required this.customerName,
    required this.phoneNumber,
    this.addressLine,
    this.note,
    this.status = 'pending',
    this.paymentStatus = 'unpaid',
    this.subtotalPrice = 0,
    this.discountAmount = 0,
    this.shippingFee = 0,
    required this.totalPrice,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List?) ?? const [];
    return OrderResponseDto(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as String?,
      customerName: json['customer_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      addressLine: json['address_line'] as String?,
      note: json['note'] as String?,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['payment_status']?.toString() ?? 'unpaid',
      subtotalPrice: (json['subtotal_price'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(OrderItemResponseDto.fromJson)
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class OrderItemResponseDto {
  final String id;
  final String orderId;
  final String? treeId;
  final String treeNameSnapshot;
  final double unitPriceSnapshot;
  final int quantity;
  final double lineTotal;
  final String? imageUrlSnapshot;
  final Map<String, dynamic> specsSnapshot;

  const OrderItemResponseDto({
    required this.id,
    required this.orderId,
    this.treeId,
    required this.treeNameSnapshot,
    required this.unitPriceSnapshot,
    this.quantity = 1,
    required this.lineTotal,
    this.imageUrlSnapshot,
    this.specsSnapshot = const {},
  });

  factory OrderItemResponseDto.fromJson(Map<String, dynamic> json) =>
      OrderItemResponseDto(
        id: json['id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        treeId: json['tree_id'] as String?,
        treeNameSnapshot: json['tree_name_snapshot']?.toString() ?? '',
        unitPriceSnapshot:
            (json['unit_price_snapshot'] as num?)?.toDouble() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
        imageUrlSnapshot: json['image_url_snapshot'] as String?,
        specsSnapshot:
            (json['specs_snapshot'] as Map?)?.cast<String, dynamic>() ?? {},
      );
}