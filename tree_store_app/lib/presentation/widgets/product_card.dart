import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppColors.green50,
                child: product.images.isNotEmpty && product.images.first.imageUrl.isNotEmpty
                    ? Image.network(product.images.first.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 40, color: AppColors.green700))
                    : const Icon(Icons.eco, size: 40, color: AppColors.green700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text('${product.finalPrice.toStringAsFixed(0)}₫', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}