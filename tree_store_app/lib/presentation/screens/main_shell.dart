import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/search')) index = 1;
    if (location.startsWith('/cart')) index = 2;
    if (location.startsWith('/profile')) index = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: AppColors.paper,
        indicatorColor: AppColors.green50, // Restore background around icon
        onDestinationSelected: (i) {
          const routes = ['/home', '/search', '/cart', '/profile'];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.home, color: AppColors.green700),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, color: AppColors.muted),
            selectedIcon: Icon(Icons.search, color: AppColors.green700, weight: 700), // Use weight for emphasis instead of strokeWidth
            label: 'Tìm kiếm',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.shopping_cart, color: AppColors.green700),
            label: 'Giỏ hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.muted),
            selectedIcon: Icon(Icons.person, color: AppColors.green700),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}