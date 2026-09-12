import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final String? id;
  final String treeId;
  final int quantity;
  final String? note;
  final Product? tree;

  const CartItem({
    this.id,
    required this.treeId,
    this.quantity = 1,
    this.note,
    this.tree,
  });

  @override
  List<Object?> get props => [id, treeId, quantity, note, tree];
}