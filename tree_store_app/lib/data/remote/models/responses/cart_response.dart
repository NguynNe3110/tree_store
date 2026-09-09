class CartItemResponseDto {
  final String? id;
  final String treeId;
  final int quantity;
  final String? note;

  const CartItemResponseDto({
    this.id,
    required this.treeId,
    this.quantity = 1,
    this.note,
  });

  factory CartItemResponseDto.fromJson(Map<String, dynamic> json) =>
      CartItemResponseDto(
        id: json['id']?.toString(),
        treeId: json['treeId']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        note: json['note'] as String?,
      );
}