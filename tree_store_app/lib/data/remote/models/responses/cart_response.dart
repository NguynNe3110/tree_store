import 'tree_response.dart';

class CartItemResponseDto {
  final String? id;
  final String treeId;
  final int quantity;
  final String? note;
  final TreeResponseDto? tree;

  const CartItemResponseDto({
    this.id,
    required this.treeId,
    this.quantity = 1,
    this.note,
    this.tree,
  });

  factory CartItemResponseDto.fromJson(Map<String, dynamic> json) {
    final rawTree = json['tree'];
    return CartItemResponseDto(
      id: json['id']?.toString(),
      treeId: json['treeId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
      tree: rawTree is Map<String, dynamic>
          ? TreeResponseDto.fromJson(rawTree)
          : null,
    );
  }
}