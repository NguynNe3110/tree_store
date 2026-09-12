import '../../domain/entities/cart_item.dart';
import '../remote/models/responses/cart_response.dart';
import 'tree_mapper.dart';

extension CartItemResponseMapper on CartItemResponseDto {
  CartItem toEntity() => CartItem(
        id: id,
        treeId: treeId,
        quantity: quantity,
        note: note,
        tree: tree?.toEntity(),
      );
}