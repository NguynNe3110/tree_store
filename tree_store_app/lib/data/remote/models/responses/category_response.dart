class CategoryResponseDto {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const CategoryResponseDto({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) =>
      CategoryResponseDto(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}