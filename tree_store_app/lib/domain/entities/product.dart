import 'package:equatable/equatable.dart';
import 'product_image.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? categoryId;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final bool isFeatured;
  final bool isActive;
  final List<ProductImage> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.categoryId,
    required this.price,
    this.discountPrice,
    this.stockQuantity = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  double get finalPrice => discountPrice ?? price;
  bool get onSale => discountPrice != null && discountPrice! < price;
  bool get inStock => stockQuantity > 0 && isActive;

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        categoryId,
        price,
        discountPrice,
        stockQuantity,
        isFeatured,
        isActive,
        images,
        createdAt,
        updatedAt,
      ];
}