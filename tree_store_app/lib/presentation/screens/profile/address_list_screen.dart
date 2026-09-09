import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: i == 0 ? Border.all(color: AppColors.green500, width: 1.5) : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Minh Anh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              if (i == 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.green700, borderRadius: BorderRadius.circular(6)), child: const Text('MẶC ĐỊNH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
              if (i != 0) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(6)), child: const Text('NHÀ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green700))),
            ]),
            const SizedBox(height: 8),
            const Text('0912 345 678', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(i == 0 ? '42 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh' : '123 Lê Lợi, Quận 3, TP. Hồ Chí Minh', style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.5)),
            const Divider(height: 24, color: AppColors.line),
            Row(children: [
              GestureDetector(onTap: () => context.push('/add-address'), child: const Text('Sửa', style: TextStyle(fontSize: 13, color: AppColors.green700, fontWeight: FontWeight.w600))),
              const SizedBox(width: 20),
              if (i != 0) ...[
                GestureDetector(onTap: () {}, child: const Text('Đặt mặc định', style: TextStyle(fontSize: 13, color: AppColors.green700, fontWeight: FontWeight.w600))),
                const SizedBox(width: 20),
              ],
              GestureDetector(onTap: () {}, child: const Text('Xoá', style: TextStyle(fontSize: 13, color: AppColors.terra, fontWeight: FontWeight.w600))),
            ]),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-address'),
        backgroundColor: AppColors.green700,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}