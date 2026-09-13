import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../blocs/auth_bloc.dart';
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
    context.read<ProfileBloc>().add(const ProfileLoad());
  }

  void _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đăng xuất', style: TextStyle(color: AppColors.terra))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const AuthLogout());
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8), // canvas bg
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state is ProfileLoaded ? state.user : (state is ProfileUpdated ? state.user : null);
          if (user == null) {
            return const Center(child: Text('Không tải được thông tin'));
          }

          final initials = user.fullName.isNotEmpty ? user.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase() : '?';
          final shortInitials = initials.length > 2 ? initials.substring(0, 2) : initials;
          final avatarUrl = user.avatarUrl != null ? resolveImageUrl(user.avatarUrl) : '';

          return Stack(
            children: [
              // Header with Gradient
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green700, AppColors.green600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              
              // Scrollable Content
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  color: AppColors.green100,
                                ),
                                child: ClipOval(
                                  child: avatarUrl.isEmpty
                                      ? Center(child: Text(shortInitials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.green700)))
                                      : Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(shortInitials))),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                                  Text(user.email ?? '', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _stat('12', 'ĐƠN HÀNG'),
                              _stat('8', 'YÊU THÍCH'),
                              _stat('450', 'ĐIỂM XANH'),
                            ],
                          ),
                          const SizedBox(height: 32), // space before menu
                        ],
                      ),
                    ),
                  ),
                  
                  // Menu Items in a White Card
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          children: [
                            _menuItem(Icons.person_outline, 'Thông tin cá nhân', 'Tên, email, số điện thoại', () => context.push('/edit-profile')),
                            _menuItem(Icons.map_outlined, 'Sổ địa chỉ', '3 địa chỉ đã lưu', () => context.push('/addresses')),
                            _menuItem(Icons.shopping_bag_outlined, 'Đơn hàng của tôi', null, () => context.push('/orders')),
                            _menuItem(Icons.favorite_outline, 'Cây yêu thích', null, null),
                            _menuItem(Icons.card_giftcard_outlined, 'Voucher của tôi', '2 voucher', null),
                            _menuItem(Icons.help_outline, 'Trợ giúp & Liên hệ', null, null),
                            _menuItem(Icons.logout, 'Đăng xuất', null, _onLogout, isLogout: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)), Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), letterSpacing: 0.6))]);

  Widget _menuItem(IconData icon, String t, String? s, VoidCallback? onTap, {bool isLogout = false}) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: isLogout ? const Color(0xFFFDE8D0) : AppColors.green50, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: isLogout ? AppColors.terra : AppColors.green700)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLogout ? AppColors.terra : AppColors.ink)),
                    if (s != null) Text(s, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
              if (!isLogout) const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      );
}