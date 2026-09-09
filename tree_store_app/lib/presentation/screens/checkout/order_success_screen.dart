import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green50, border: Border.all(color: AppColors.green700, width: 2, strokeAlign: BorderSide.strokeAlignOutside)),
                child: const Icon(Icons.check, size: 48, color: AppColors.green700),
              ),
              const SizedBox(height: 24),
              const Text('Đặt hàng thành công!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 12),
              const Text('Cảm ơn bạn đã tin tưởng Verdant\nChúng tôi sẽ giao cây tới bạn thật cẩn thận.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)), child: const Text('MÃ ĐƠN #VD-2026-08402', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.green700))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Thanh toán', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('COD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Dự kiến giao', style: TextStyle(fontSize: 13, color: AppColors.muted)), const Text('10/09/2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]),
                ]),
              ),
              const Spacer(),
              PrimaryButton(label: 'Xem chi tiết đơn', onPressed: () => context.go('/order/VD-2026-08402')),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 48, child: OutlinedButton(onPressed: () => context.go('/home'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.green700), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Tiếp tục mua sắm', style: TextStyle(color: AppColors.green700)))),
            ],
          ),
        ),
      ),
    );
  }
}