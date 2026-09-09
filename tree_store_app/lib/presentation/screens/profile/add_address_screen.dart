import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _type = 'Nhà';
  bool _isDefault = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm địa chỉ mới')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          const Text('THÔNG TIN LIÊN HỆ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          _field('Họ và tên người nhận', 'Minh Anh'),
          _field('Số điện thoại', '0912 345 678'),
          const SizedBox(height: 24),
          const Text('ĐỊA CHỈ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          _dropdown('Tỉnh / Thành phố', 'TP. Hồ Chí Minh'),
          _dropdown('Quận / Huyện', 'Quận 1'),
          _dropdown('Phường / Xã', 'Phường Bến Nghé'),
          _field('Địa chỉ cụ thể', '42 Nguyễn Huệ'),
          const SizedBox(height: 24),
          const Text('LOẠI ĐỊA CHỈ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          Row(children: [
            _typePill('🏠 Nhà'), _typePill('🏢 Công ty'), _typePill('📍 Khác'),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Text('Sử dụng cho các đơn hàng tiếp theo', style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ])),
            Switch(value: _isDefault, onChanged: (v) => setState(() => _isDefault = v), activeColor: AppColors.green700),
          ]),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
        child: SafeArea(child: PrimaryButton(label: 'Lưu địa chỉ', onPressed: () => context.pop())),
      ),
    );
  }

  Widget _field(String label, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(decoration: InputDecoration(labelText: label, hintText: hint, fillColor: AppColors.green50)),
  );

  Widget _dropdown(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))]),
        const Icon(Icons.chevron_right, color: AppColors.muted),
      ]),
    ),
  );

  Widget _typePill(String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _type = label.substring(2).trim()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _type == label.substring(2).trim() ? AppColors.green50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _type == label.substring(2).trim() ? AppColors.green700 : AppColors.line),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _type == label.substring(2).trim() ? AppColors.green700 : AppColors.muted)),
      ),
    ),
  );
}