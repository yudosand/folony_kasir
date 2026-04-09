import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../domain/entities/product.dart';
import '../../presentation/auth/controllers/session_controller.dart';
import '../../presentation/auth/login/login_page.dart';
import '../../presentation/auth/register/register_page.dart';
import '../../presentation/cart/pages/cart_page.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/invoice/pages/invoice_page.dart';
import '../../presentation/manual_transaction/pages/manual_transaction_page.dart';
import '../../presentation/products/pages/product_form_page.dart';
import '../../presentation/products/pages/product_list_page.dart';
import '../../presentation/settings/pages/settings_page.dart';
import '../../presentation/splash/splash_page.dart';
import '../../presentation/shared/main_shell_page.dart';
import '../../presentation/transactions/pages/transaction_list_page.dart';
import 'router_refresh_listenable.dart';

final routerRefreshListenableProvider =
    Provider<RouterRefreshListenable>((ref) {
  final listenable = RouterRefreshListenable();

  ref.listen(sessionControllerProvider, (_, __) {
    listenable.notify();
  });
  ref.onDispose(listenable.dispose);

  return listenable;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const ProductListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                builder: (context, state) => const TransactionListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.manualTransaction,
        builder: (context, state) => const ManualTransactionPage(),
      ),
      GoRoute(
        path: AppRoutes.productCreate,
        builder: (context, state) => const ProductFormPage(),
      ),
      GoRoute(
        path: '/products/:productId/edit',
        builder: (context, state) {
          final product = state.extra;
          if (product is! Product) {
            return const ProductListPage();
          }

          return ProductFormPage(product: product);
        },
      ),
      GoRoute(
        path: '/transactions/:transactionId/invoice',
        builder: (context, state) {
          final transactionId = int.tryParse(
            state.pathParameters['transactionId'] ?? '',
          );

          if (transactionId == null) {
            return const TransactionListPage();
          }

          return InvoicePage(transactionId: transactionId);
        },
      ),
    ],
    redirect: (context, state) {
      final sessionState = ref.read(sessionControllerProvider);
      final isLoading = sessionState.isLoading;
      final isAuthenticated = sessionState.valueOrNull != null;
      final currentPath = state.matchedLocation;
      final isAuthPath =
          currentPath == AppRoutes.login || currentPath == AppRoutes.register;

      if (isLoading) {
        return currentPath == AppRoutes.splash || isAuthPath
            ? null
            : AppRoutes.splash;
      }

      if (!isAuthenticated) {
        return isAuthPath ? null : AppRoutes.login;
      }

      if (currentPath == AppRoutes.splash || isAuthPath) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});
