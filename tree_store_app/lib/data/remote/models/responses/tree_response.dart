class TreeImageResponseDto {
  final String id;
  final String imageUrl;
  final int sortOrder;

  const TreeImageResponseDto({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  factory TreeImageResponseDto.fromJson(Map<String, dynamic> json) =>
      TreeImageResponseDto(
        id: json['id']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString() ?? '',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      );
}

class TreeResponseDto {
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String status;
  final double? heightCm;
  final double? potDiameterCm;
  final double? trunkDiameterCm;
  final int? ageYears;
  final String? location;
  final String? careNote;
  final List<String> tags;
  final String? coverImageUrl;
  final bool isFeatured;
  final bool isActive;
  final List<TreeImageResponseDto> images;

  const TreeResponseDto({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    required this.price,
    this.discountPrice,
    this.stockQuantity = 1,
    this.status = 'available',
    this.heightCm,
    this.potDiameterCm,
    this.trunkDiameterCm,
    this.ageYears,
    this.location,
    this.careNote,
    this.tags = const [],
    this.coverImageUrl,
    this.isFeatured = false,
    this.isActive = true,
    this.images = const [],
  });

  factory TreeResponseDto.fromJson(Map<String, dynamic> json) {
    final rawImages = (json['images'] as List?) ?? const [];
    final rawTags = (json['tags'] as List?) ?? const [];
    return TreeResponseDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'available',
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      potDiameterCm: (json['potDiameterCm'] as num?)?.toDouble(),
      trunkDiameterCm: (json['trunkDiameterCm'] as num?)?.toDouble(),
      ageYears: (json['ageYears'] as num?)?.toInt(),
      location: json['location'] as String?,
      careNote: json['careNote'] as String?,
      tags: rawTags.map((e) => e.toString()).toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      images: rawImages
          .whereType<Map<String, dynamic>>()
          .map(TreeImageResponseDto.fromJson)
          .toList(),
    );
  }
}