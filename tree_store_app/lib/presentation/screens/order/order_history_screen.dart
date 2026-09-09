import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: Column(
        children: [
          Container(
            color: AppColors.paper,
            child: Row(children: [
              _tab('Tất cả', false),
              _tab('Đang giao', true),
              _tab('Đã giao', false),
              _tab('Đã huỷ', false),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('#VD-2026-0840${i + 1}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.muted)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(6)), child: const Text('ĐANG GIAO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green700))),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.eco, color: AppColors.green700)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Trầu bà Monstera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('Đặt 08/09/2026 · ${i + 1} sản phẩm', style: const TextStyle(fontSize: 12, color: AppColors.muted))])),
                  ]),
                  const Divider(height: 24, color: AppColors.line),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng thanh toán', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('450.000₫', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.green700))]),
                  const SizedBox(height: 8),
                  GestureDetector(onTap: () => context.push('/order/VD-2026-0840${i + 1}'), child: const Align(alignment: Alignment.centerRight, child: Text('Xem chi tiết →', style: TextStyle(fontSize: 13, color: AppColors.green700, fontWeight: FontWeight.w600)))),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? AppColors.green700 : Colors.transparent, width: 2))),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.normal, color: active ? AppColors.green700 : AppColors.muted)),
    ),
  );
}