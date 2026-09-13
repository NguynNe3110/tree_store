import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import '../remote/models/responses/tree_response.dart';

extension TreeImageResponseMapper on TreeImageResponseDto {
  ProductImage toEntity(String treeId) => ProductImage(
        id: id,
        productId: treeId,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
      );
}

extension TreeResponseMapper on TreeResponseDto {
  Product toEntity() => Product(
        id: id,
        name: name,
        slug: id, // ponytail: backend has no slug, use id as fallback. upgrade when backend adds slug field
        description: description,
        categoryId: categoryId,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        isFeatured: isFeatured,
        isActive: isActive,
        images: images.isNotEmpty
            ? images.map((e) => e.toEntity(id)).toList()
            : [
                if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                  ProductImage(
                    id: 'cover-$id',
                    productId: id,
                    imageUrl: coverImageUrl!,
                    sortOrder: 0,
                  )
              ],
      );
}