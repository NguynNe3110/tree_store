import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final bool paid;
  const OrderSuccessScreen({super.key, this.orderId = '', this.paid = false});

  @override
  Widget build(BuildContext context) {
    final shortId = orderId.isEmpty
        ? '—'
        : orderId.substring(0, orderId.length > 8 ? 8 : orderId.length).toUpperCase();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green50,
                  border: Border.all(color: AppColors.green700, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                ),
                child: const Icon(Icons.check, size: 48, color: AppColors.green700),
              ),
              const SizedBox(height: 24),
              const Text('Đặt hàng thành công!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 12),
              const Text('Cảm ơn bạn đã tin tưởng Verdant\nChúng tôi sẽ giao cây tới bạn thật cẩn thận.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
                child: Text('MÃ ĐƠN #$shortId', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.green700)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Thanh toán', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                      Text(paid ? 'Đã thanh toán' : 'COD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: paid ? AppColors.green700 : AppColors.ink)),
                    ]),
                    const Divider(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Trạng thái', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                      Text(paid ? 'Đã xác nhận' : 'Đang xử lý', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Xem chi tiết đơn',
                onPressed: () => orderId.isEmpty ? context.go('/orders') : context.go('/order/$orderId'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.green700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tiếp tục mua sắm', style: TextStyle(color: AppColors.green700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}