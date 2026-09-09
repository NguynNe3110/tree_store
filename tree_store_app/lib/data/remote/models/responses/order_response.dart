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
      userId: json['userId'] as String?,
      customerName: json['customerName']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      addressLine: json['addressLine'] as String?,
      note: json['note'] as String?,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      subtotalPrice: (json['subtotalPrice'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      items: raw
          .whereType<Map<String, dynamic>>()
          .map(OrderItemResponseDto.fromJson)
          .toList(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
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
        orderId: json['orderId']?.toString() ?? '',
        treeId: json['treeId'] as String?,
        treeNameSnapshot: json['treeNameSnapshot']?.toString() ?? '',
        unitPriceSnapshot:
            (json['unitPriceSnapshot'] as num?)?.toDouble() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0,
        imageUrlSnapshot: json['imageUrlSnapshot'] as String?,
        specsSnapshot:
            (json['specsSnapshot'] as Map?)?.cast<String, dynamic>() ?? {},
      );
}