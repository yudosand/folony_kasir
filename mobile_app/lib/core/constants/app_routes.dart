class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String products = '/products';
  static const String productCreate = '/products/new';
  static const String cart = '/cart';
  static const String transactions = '/transactions';
  static const String manualTransaction = '/manual-transaction';
  static const String settings = '/settings';

  const AppRoutes._();

  static String productEdit(int productId) => '/products/$productId/edit';
  static String transactionInvoice(int transactionId) =>
      '/transactions/$transactionId/invoice';
}
