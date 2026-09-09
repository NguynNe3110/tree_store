import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _gender = 'Nam';
  bool _promoNotif = true;
  bool _careTips = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân'), actions: [TextButton(onPressed: () => context.pop(), child: const Text('Lưu', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700)))]),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Stack(children: [
            Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green100), child: const Center(child: Text('MA', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.green700)))),
            Positioned(bottom: 0, right: 0, child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.line)), child: const Icon(Icons.edit, size: 14, color: AppColors.green700))),
          ])),
          const SizedBox(height: 8),
          const Center(child: Text('Đổi ảnh đại diện', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green700))),
          const SizedBox(height: 24),
          _field('Họ và tên', 'Minh Anh'),
          _field('Email', 'minhanh@verdant.vn'),
          _field('Số điện thoại', '0912 345 678'),
          _field('Ngày sinh', '15/03/1998'),
          const SizedBox(height: 16),
          Row(children: [
            _genderPill('Nam'), _genderPill('Nữ'), _genderPill('Khác'),
          ]),
          const Divider(height: 40, color: AppColors.line),
          _toggleRow('Nhận thông báo khuyến mãi', 'Email & push notification', _promoNotif, (v) => setState(() => _promoNotif = v)),
          _toggleRow('Mẹo chăm sóc cây hằng tuần', 'Vào 8:00 sáng thứ 2', _careTips, (v) => setState(() => _careTips = v)),
        ],
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))])),
  );

  Widget _genderPill(String label) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _gender == label ? AppColors.green50 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gender == label ? AppColors.green700 : AppColors.line)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _gender == label ? AppColors.green700 : AppColors.muted)),
      ),
    ),
  );

  Widget _toggleRow(String title, String sub, bool value, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.muted))])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.green700),
    ]),
  );
}