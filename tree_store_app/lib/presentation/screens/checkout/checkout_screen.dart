import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.location_on, color: AppColors.green700, size: 20), const SizedBox(width: 8), const Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), TextButton(onPressed: () => context.push('/addresses'), child: const Text('Đổi'))]), const SizedBox(height: 8), const Text('Minh Anh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), const Text('0912 345 678', style: TextStyle(fontSize: 12, color: AppColors.muted)), const Text('42 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM', style: TextStyle(fontSize: 13, color: AppColors.ink2))])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sản phẩm (3)', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 12), ...List.generate(3, (i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, size: 20, color: AppColors.green700)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cây ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), const Text('Chậu gốm', style: TextStyle(fontSize: 11, color: AppColors.muted))])), const Text('×1', style: TextStyle(fontSize: 12, color: AppColors.muted)), const SizedBox(width: 8), const Text('250.000₫', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green700))])))])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 12), RadioListTile<String>(value: 'cod', groupValue: 'cod', onChanged: (_) {}, title: const Text('Thanh toán khi nhận hàng (COD)'), dense: true, activeColor: AppColors.green700), RadioListTile<String>(value: 'bank', groupValue: 'cod', onChanged: (_) {}, title: const Text('Chuyển khoản ngân hàng'), subtitle: const Text('VCB · TCB · MB', style: TextStyle(fontSize: 11, color: AppColors.muted)), dense: true, activeColor: AppColors.green700)])),
          const SizedBox(height: 16),
          TextField(maxLines: 2, decoration: InputDecoration(hintText: 'Ghi chú cho shop...', fillColor: AppColors.green50)),
        ],
      ),
      bottomSheet: Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))), child: Row(children: [const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tổng cộng', style: TextStyle(fontSize: 12, color: AppColors.muted)), Text('622.000₫', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green700))]), const SizedBox(width: 16), Expanded(child: PrimaryButton(label: 'Đặt hàng', onPressed: () => context.push('/order-success?id=VD-2026-08402')))])),
    );
  }
}