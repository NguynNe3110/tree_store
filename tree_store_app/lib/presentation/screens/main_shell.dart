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
        indicatorColor: AppColors.green50,
        onDestinationSelected: (i) {
          const routes = ['/home', '/search', '/cart', '/profile'];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}