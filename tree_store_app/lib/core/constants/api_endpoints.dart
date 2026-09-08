class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';

  // Tree
  static const String trees = '/api/trees';
  static const String treeDetail = '/api/trees/{id}';
  static const String categories = '/api/categories';

  // Order
  static const String orders = '/api/orders';
  static const String orderDetail = '/api/orders/{id}';

  // Profile
  static const String profile = '/api/profile';
}