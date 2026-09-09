import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.green700, AppColors.green600], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(children: [
              Row(children: [
                Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green100, border: Border.all(color: Colors.white, width: 3)), child: const Center(child: Text('MA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.green700)))),
                const SizedBox(width: 16),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Minh Anh', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)), SizedBox(height: 4), Text('minhanh@verdant.vn', style: TextStyle(fontSize: 12, color: Colors.white70))]),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat('12', 'Đơn hàng'), _stat('8', 'Cây yêu thích'), _stat('450', 'Điểm xanh'),
              ]),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))]),
              child: Column(children: [
                _menuItem(Icons.person_outline, 'Thông tin cá nhân', () => context.push('/edit-profile')),
                _menuItem(Icons.location_on_outlined, 'Sổ địa chỉ (3 đã lưu)', () => context.push('/addresses')),
                _menuItem(Icons.receipt_long_outlined, 'Đơn hàng', () => context.push('/orders')),
                _menuItem(Icons.favorite_border, 'Cây yêu thích', null),
                _menuItem(Icons.local_offer_outlined, 'Voucher (2)', null),
                _menuItem(Icons.help_outline, 'Trợ giúp', null),
                _menuItem(Icons.logout, 'Đăng xuất', null, isLogout: true),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _stat(String value, String label) => Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(height: 4), Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white70))]);

  Widget _menuItem(IconData icon, String title, VoidCallback? onTap, {bool isLogout = false}) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: isLogout ? AppColors.terraBg : AppColors.green50, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: isLogout ? AppColors.terra : AppColors.green700)),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLogout ? AppColors.terra : AppColors.ink))),
        if (!isLogout) const Icon(Icons.chevron_right, color: AppColors.green700, size: 20),
      ]),
    ),
  );
}