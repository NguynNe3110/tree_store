import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String? id;
  final String treeId;
  final int quantity;
  final String? note;

  const CartItem({
    this.id,
    required this.treeId,
    this.quantity = 1,
    this.note,
  });

  @override
  List<Object?> get props => [id, treeId, quantity, note];
}