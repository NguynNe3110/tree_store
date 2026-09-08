import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props =>
      [id, name, description, imageUrl, sortOrder, isActive];
}