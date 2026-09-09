class OrderItemRequestDto {
  final String treeId;
  final int quantity;
  const OrderItemRequestDto({required this.treeId, required this.quantity});

  Map<String, dynamic> toJson() => {'treeId': treeId, 'quantity': quantity};
}

class CreateOrderRequestDto {
  final String customerName;
  final String phoneNumber;
  final String addressLine;
  final String? note;
  final List<OrderItemRequestDto> items;
  final String paymentMethod;
  final double shippingFee;
  final double discountAmount;
  const CreateOrderRequestDto({
    required this.customerName,
    required this.phoneNumber,
    required this.addressLine,
    this.note,
    required this.items,
    this.paymentMethod = 'cod',
    this.shippingFee = 0,
    this.discountAmount = 0,
  });

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'phoneNumber': phoneNumber,
        'addressLine': addressLine,
        if (note != null) 'note': note,
        'items': items.map((e) => e.toJson()).toList(),
        'paymentMethod': paymentMethod,
        'shippingFee': shippingFee,
        'discountAmount': discountAmount,
      };
}