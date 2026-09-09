import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
            actions: [IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {})],
            flexibleSpace: FlexibleSpaceBar(background: Container(color: AppColors.green50, child: const Center(child: Icon(Icons.eco, size: 80, color: AppColors.green700)))),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CÂY TRONG NHÀ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green700, letterSpacing: 0.05)),
                  const SizedBox(height: 4),
                  const Text('Trầu bà Monstera', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Row(children: <Widget>[...List.generate(5, (_) => const Icon(Icons.star, size: 16, color: Colors.amber)), const SizedBox(width: 4), const Text('4.9 · 128 đánh giá · Còn 12', style: TextStyle(fontSize: 13, color: AppColors.muted))]),
                  const SizedBox(height: 12),
                  Row(children: [const Text('450.000₫', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.green700)), const SizedBox(width: 8), const Text('560.000₫', style: TextStyle(fontSize: 16, color: AppColors.muted, decoration: TextDecoration.lineThrough)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.terraBg, borderRadius: BorderRadius.circular(6)), child: const Text('-20%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.terra)))]),
                  const SizedBox(height: 20),
                  GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2, children: [['Chiều cao', '60-70cm'], ['Tưới nước', '2 lần/tuần'], ['Ánh sáng', 'Gián tiếp'], ['Độ khó', 'Dễ chăm'], ['Vị trí', 'Trong nhà'], ['Chậu kèm', 'Có']].map((a) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(a[0], style: const TextStyle(fontSize: 10, color: AppColors.muted)), const SizedBox(height: 2), Text(a[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink))]))).toList()),
                  const SizedBox(height: 20),
                  const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  const Text('Cây trầu bà Monstera là loại cây cảnh phổ biến với lá xẻ thùy đặc trưng. Phù hợp trang trí nội thất, dễ chăm sóc và có khả năng lọc không khí tốt.', style: TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.6)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_cart_outlined, color: AppColors.green700)),
            const SizedBox(width: 12),
            Expanded(child: PrimaryButton(label: 'Mua ngay · 450.000₫', onPressed: () => context.push('/checkout'))), // ponytail: no BLoC yet
          ],
        ),
      ),
    );
  }
}