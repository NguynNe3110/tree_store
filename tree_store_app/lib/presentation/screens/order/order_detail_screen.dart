import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class OrderDetailScreen extends StatelessWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$id')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.green700, AppColors.green600]), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TRẠNG THÁI', style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white70)),
              const SizedBox(height: 4),
              const Text('Đang trên đường giao', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Dự kiến giao: 10/09/2026 · 14:00 – 18:00', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _timelineItem('Đơn hàng đã đặt', '08/09/2026 10:30', true),
              _timelineItem('Đã xác nhận', '08/09/2026 11:00', true),
              _timelineItem('Đang giao', '09/09/2026 08:00', false), // ponytail: no real timeline data yet
              _timelineItem('Giao thành công', '', false),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tạm tính', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('740.000₫', style: TextStyle(fontSize: 13))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Phí giao', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('30.000₫', style: TextStyle(fontSize: 13))]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Giảm giá', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('-148.000₫', style: TextStyle(fontSize: 13, color: AppColors.terra))]),
              const Divider(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng cộng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), const Text('622.000₫', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.green700))]),
            ]),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
        child: SafeArea(child: Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), side: const BorderSide(color: AppColors.green700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Liên hệ shop', style: TextStyle(color: AppColors.green700)))),
          const SizedBox(width: 12),
          Expanded(child: PrimaryButton(label: 'Theo dõi', onPressed: () {})),
        ])),
      ),
    );
  }

  Widget _timelineItem(String title, String meta, bool done) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: done ? AppColors.green700 : AppColors.line)),
        if (!done) Container(width: 2, height: 30, color: AppColors.line),
      ]),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: done ? AppColors.ink : AppColors.muted)),
        if (meta.isNotEmpty) Text(meta, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    ]),
  );
}