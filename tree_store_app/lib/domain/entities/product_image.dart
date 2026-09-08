import 'package:equatable/equatable.dart';

class ProductImage extends Equatable {
  final String id;
  final String productId;
  final String imageUrl;
  final String? alt;
  final int sortOrder;
  final DateTime? createdAt;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.alt,
    this.sortOrder = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, productId, imageUrl, alt, sortOrder, createdAt];
}