import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/notification/notification_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/product/product_list_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/pay_webview_screen.dart';
import '../../presentation/screens/checkout/order_success_screen.dart';
import '../../presentation/screens/order/order_history_screen.dart';
import '../../presentation/screens/order/order_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/address_list_screen.dart';
import '../../presentation/screens/profile/add_address_screen.dart';
import '../../domain/entities/product.dart';
import '../network/token_storage.dart';

// ponytail: simple sync flag for auth guard. upgrade to stream/BLoC when real auth state needed
bool isAuthenticated = false;

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(TokenStorage tokenStorage) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final token = await tokenStorage.getAccessToken();
      final loggedIn = token != null && token.isNotEmpty;
      isAuthenticated = loggedIn;
      final loc = state.matchedLocation;
      if (loc == '/splash') return null;
      final isAuthRoute = loc == '/login' || loc == '/register' || loc == '/forgot-password' || loc == '/otp';
      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (_, s) => ResetPasswordScreen(email: s.uri.queryParameters['email'] ?? '')),
      GoRoute(path: '/otp', builder: (_, s) => OtpScreen(email: s.uri.queryParameters['email'] ?? '', purpose: s.uri.queryParameters['purpose'] ?? 'register')),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen())),
          GoRoute(path: '/search', pageBuilder: (_, __) => const NoTransitionPage(child: SearchScreen())),
          GoRoute(path: '/cart', pageBuilder: (_, __) => const NoTransitionPage(child: CartScreen())),
          GoRoute(path: '/profile', pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen())),
        ],
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
      GoRoute(path: '/product/:id', builder: (_, s) => ProductDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(
        path: '/product-list',
        builder: (_, s) => ProductListScreen(title: s.uri.queryParameters['title'] ?? 'Sản phẩm'),
      ),
      GoRoute(path: '/checkout', builder: (_, s) {
        final extra = s.extra as Map<String, dynamic>?;
        return CheckoutScreen(
          singleItem: extra?['singleItem'] as Product?,
          quantity: extra?['quantity'] as int? ?? 1,
        );
      }),
      GoRoute(path: '/pay-webview', builder: (_, s) {
        final extra = s.extra as Map<String, dynamic>?;
        return PayWebviewScreen(
          orderId: extra?['orderId'] as String? ?? '',
          url: extra?['url'] as String? ?? '',
        );
      }),
      GoRoute(path: '/order-success', builder: (_, s) => OrderSuccessScreen(orderId: s.uri.queryParameters['id'] ?? '', paid: s.uri.queryParameters['paid'] == '1')),
      GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/order/:id', builder: (_, s) => OrderDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressListScreen()),
      GoRoute(path: '/add-address', builder: (_, __) => const AddAddressScreen()),
    ],
  );
}