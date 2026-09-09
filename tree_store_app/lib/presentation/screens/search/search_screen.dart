import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: AppColors.muted), hintText: 'Tìm cây, chậu, phụ kiện...', fillColor: AppColors.green50))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Wrap(spacing: 8, children: ['Trong nhà', 'Dễ chăm', '< 300k'].map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 12)), backgroundColor: AppColors.green50, deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () {})).toList())),
          const SizedBox(height: 8),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Text('Tìm thấy 24 cây', style: TextStyle(fontSize: 13, color: AppColors.muted)), Spacer(), Text('Giá thấp nhất ↓', style: TextStyle(fontSize: 13, color: AppColors.green700, fontWeight: FontWeight.w600))])),
          Expanded(child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7), itemCount: 6, itemBuilder: (_, i) => Container(decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 120, decoration: const BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: const Center(child: Icon(Icons.eco, size: 36, color: AppColors.green700))), Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cây ${i + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('250.000₫', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.green700))]))]))),),
        ],
      ),
    );
  }
}