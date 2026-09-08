import '../../domain/entities/category.dart';
import '../remote/models/responses/category_response.dart';

extension CategoryResponseMapper on CategoryResponseDto {
  Category toEntity() => Category(
        id: id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
        isActive: isActive,
      );
}