import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('[DEBUG] ProfileScreen initState, dispatching ProfileLoad');
    context.read<ProfileBloc>().add(const ProfileLoad());
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            debugPrint('[DEBUG] ProfileScreen error: ${state.message}');
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.terra)));
          }
          if (state is ProfileLoaded || state is ProfileUpdated) {
            final user = state is ProfileLoaded ? state.user : (state as ProfileUpdated).user;
            final initials = _initials(user.fullName);
            // ponytail: stats hardcoded client-side. upgrade when backend provides order count / points API
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.green700, AppColors.green600], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Column(children: [
                    Row(children: [
                      Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green100, border: Border.all(color: Colors.white, width: 3)), child: Center(child: Text(initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.green700)))),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(user.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ]),
                    ]),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _stat('0', 'Đơn hàng'), _stat('0', 'Cây quan tâm'), _stat('0', 'Điểm xanh'),
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
                      _menuItem(Icons.location_on_outlined, 'Sổ địa chỉ', () => context.push('/addresses')),
                      _menuItem(Icons.receipt_long_outlined, 'Đơn hàng', () => context.push('/orders')),
                      _menuItem(Icons.favorite_border, 'Cây yêu thích', null),
                      _menuItem(Icons.local_offer_outlined, 'Voucher', null),
                      _menuItem(Icons.help_outline, 'Trợ giúp', null),
                      _menuItem(Icons.logout, 'Đăng xuất', () {
                        debugPrint('[DEBUG] Logout tapped');
                        context.go('/login');
                      }, isLogout: true),
                    ]),
                  ),
                ),
              ),
            ]);
          }
          return const SizedBox.shrink();
        },
      ),
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