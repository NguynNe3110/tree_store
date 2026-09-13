class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // Home SDUI
  static const String home = '/api/home';

  // Tree
  static const String trees = '/api/trees';
  static const String featuredTrees = '/api/trees/featured';
  static const String treeDetail = '/api/trees/{id}';
  static const String categories = '/api/categories';

  // Cart
  static const String cart = '/api/cart';
  static const String cartItem = '/api/cart/{id}';

  // Order
  static const String orders = '/api/orders';
  static const String orderDetail = '/api/orders/{id}';

  // Profile
  static const String profile = '/api/profile';
  static const String avatar = '/api/profile/avatar';
  static const String addresses = '/api/profile/addresses';
}