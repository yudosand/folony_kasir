import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/network_config.dart';
import '../core/network/session_invalidation_bus.dart';
import '../core/storage/token_storage.dart';
import '../data/datasources/local/auth_local_data_source.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/remote/member_point_remote_data_source.dart';
import '../data/datasources/remote/product_remote_data_source.dart';
import '../data/datasources/remote/store_setting_remote_data_source.dart';
import '../data/datasources/remote/transaction_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/member_point_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/store_setting_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/member_point_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/store_setting_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/create_product_use_case.dart';
import '../domain/usecases/create_transaction_use_case.dart';
import '../domain/usecases/delete_product_use_case.dart';
import '../domain/usecases/get_member_point_member_use_case.dart';
import '../domain/usecases/get_invoice_use_case.dart';
import '../domain/usecases/get_products_use_case.dart';
import '../domain/usecases/get_store_setting_use_case.dart';
import '../domain/usecases/get_transactions_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/register_use_case.dart';
import '../domain/usecases/restore_session_use_case.dart';
import '../domain/usecases/update_store_setting_use_case.dart';
import '../domain/usecases/update_product_use_case.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final sessionInvalidationBusProvider = Provider<SessionInvalidationBus>((ref) {
  return SessionInvalidationBus();
});

final dioProvider = Provider<Dio>((ref) {
  return ApiClient.create(
    baseUrl: NetworkConfig.apiBaseUrl,
    interceptors: [
      AuthInterceptor(
        tokenStorage: ref.watch(tokenStorageProvider),
        sessionInvalidationBus: ref.watch(sessionInvalidationBusProvider),
      ),
      if (NetworkConfig.enableNetworkLogs)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
    ],
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(tokenStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(dioProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productRemoteDataSourceProvider));
});

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
  return TransactionRemoteDataSource(ref.watch(dioProvider));
});

final memberPointRemoteDataSourceProvider =
    Provider<MemberPointRemoteDataSource>((ref) {
  return MemberPointRemoteDataSource(ref.watch(dioProvider));
});

final storeSettingRemoteDataSourceProvider =
    Provider<StoreSettingRemoteDataSource>((ref) {
  return StoreSettingRemoteDataSource(ref.watch(dioProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
      ref.watch(transactionRemoteDataSourceProvider));
});

final storeSettingRepositoryProvider = Provider<StoreSettingRepository>((ref) {
  return StoreSettingRepositoryImpl(
    ref.watch(storeSettingRemoteDataSourceProvider),
  );
});

final memberPointRepositoryProvider = Provider<MemberPointRepository>((ref) {
  return MemberPointRepositoryImpl(ref.watch(memberPointRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

final createTransactionUseCaseProvider =
    Provider<CreateTransactionUseCase>((ref) {
  return CreateTransactionUseCase(ref.watch(transactionRepositoryProvider));
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  return GetTransactionsUseCase(ref.watch(transactionRepositoryProvider));
});

final getInvoiceUseCaseProvider = Provider<GetInvoiceUseCase>((ref) {
  return GetInvoiceUseCase(ref.watch(transactionRepositoryProvider));
});

final getMemberPointMemberUseCaseProvider =
    Provider<GetMemberPointMemberUseCase>((ref) {
  return GetMemberPointMemberUseCase(ref.watch(memberPointRepositoryProvider));
});

final getStoreSettingUseCaseProvider = Provider<GetStoreSettingUseCase>((ref) {
  return GetStoreSettingUseCase(ref.watch(storeSettingRepositoryProvider));
});

final updateStoreSettingUseCaseProvider =
    Provider<UpdateStoreSettingUseCase>((ref) {
  return UpdateStoreSettingUseCase(ref.watch(storeSettingRepositoryProvider));
});
