class ApiConstants {
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String storeSetting = '/store-setting';
  static const String products = '/products';
  static const String stockBookkeeping = '/stock-bookkeeping';
  static const String stockBookkeepingReport = '/stock-bookkeeping/report';
  static const String transactions = '/transactions';
  static const String memberPointMembers = '/member-points/members';
  static const String memberPointMutations = '/member-points/mutations';

  const ApiConstants._();

  static String stockCard(int productId) => '$products/$productId/stock-card';
  static String stockRestocks(int productId) => '$products/$productId/restocks';
  static String stockAdjustments(int productId) =>
      '$products/$productId/adjustments';
}
