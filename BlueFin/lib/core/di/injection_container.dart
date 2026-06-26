import 'package:BlueFin/core/network/network_info.dart';
import 'package:BlueFin/core/services/supabase_service.dart';
import 'package:BlueFin/core/services/user_id_provider.dart';
import 'package:BlueFin/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:BlueFin/features/analytics/domain/usecases/get_spending_summary.dart';
import 'package:BlueFin/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:BlueFin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:BlueFin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:BlueFin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:BlueFin/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:BlueFin/features/auth/domain/usecases/get_current_user.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_in.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_out.dart';
import 'package:BlueFin/features/auth/domain/usecases/sign_up.dart';
import 'package:BlueFin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:BlueFin/features/balance/data/datasources/balance_local_data_source.dart';
import 'package:BlueFin/features/balance/data/datasources/balance_remote_data_source.dart';
import 'package:BlueFin/features/balance/data/repositories/balance_repository_impl.dart';
import 'package:BlueFin/features/balance/domain/repositories/i_balance_repository.dart';
import 'package:BlueFin/features/balance/domain/usecases/get_balance.dart';
import 'package:BlueFin/features/balance/domain/usecases/update_balance.dart';
import 'package:BlueFin/features/balance/presentation/bloc/balance_bloc.dart';
import 'package:BlueFin/features/categories/data/datasources/category_local_data_source.dart';
import 'package:BlueFin/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:BlueFin/features/categories/data/repositories/category_repository_impl.dart';
import 'package:BlueFin/features/categories/domain/repositories/i_category_repository.dart';
import 'package:BlueFin/features/categories/domain/usecases/add_category.dart';
import 'package:BlueFin/features/categories/domain/usecases/delete_category.dart';
import 'package:BlueFin/features/categories/domain/usecases/get_categories.dart';
import 'package:BlueFin/features/categories/domain/usecases/update_category.dart';
import 'package:BlueFin/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:BlueFin/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:BlueFin/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:BlueFin/features/currency/data/repositories/currency_repository_impl.dart';
import 'package:BlueFin/features/currency/domain/repositories/i_currency_repository.dart';
import 'package:BlueFin/features/currency/domain/usecases/convert_currency.dart';
import 'package:BlueFin/features/currency/domain/usecases/get_exchange_rates.dart';
import 'package:BlueFin/features/currency/presentation/cubit/currency_cubit.dart';
import 'package:BlueFin/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:BlueFin/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:BlueFin/features/settings/domain/repositories/i_settings_repository.dart';
import 'package:BlueFin/features/settings/domain/usecases/get_settings.dart';
import 'package:BlueFin/features/settings/domain/usecases/save_settings.dart';
import 'package:BlueFin/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:BlueFin/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:BlueFin/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:BlueFin/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:BlueFin/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:BlueFin/features/transactions/domain/usecases/add_transaction.dart';
import 'package:BlueFin/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:BlueFin/features/transactions/domain/usecases/get_transactions.dart';
import 'package:BlueFin/features/transactions/domain/usecases/update_transaction.dart';
import 'package:BlueFin/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // UserIdProvider
  sl.registerLazySingleton<UserIdProvider>(() => UserIdProvider(sl<SharedPreferences>()));

  // Dio
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  )));

  // Network
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Connectivity>()));

  //AUTH
  sl.registerLazySingleton<IAuthLocalDataSource>(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton<IAuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl(
      sl<IAuthLocalDataSource>(),
      sl<IAuthRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
    signIn: sl(),
    signUp: sl(),
    getCurrentUser: sl(),
    signOut: sl(),
  ));

  // BALANCE
  sl.registerLazySingleton<IBalanceLocalDataSource>(() => BalanceLocalDataSource(sl()));
  sl.registerLazySingleton<IBalanceRemoteDataSource>(() => BalanceRemoteDataSource());
  sl.registerLazySingleton<IBalanceRepository>(
        () => BalanceRepositoryImpl(
      local: sl<IBalanceLocalDataSource>(),
      remote: sl<IBalanceRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      userIdProvider: sl<UserIdProvider>(),
    ),
  );
  sl.registerLazySingleton(() => GetBalanceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBalanceUseCase(sl()));
  sl.registerFactory(() => BalanceBloc(
    getBalance: sl(),
    updateBalance: sl(),
  ));

  //TRANSACTIONS
  sl.registerLazySingleton<ITransactionLocalDataSource>(() => TransactionLocalDataSource(sl()));
  sl.registerLazySingleton<ITransactionRemoteDataSource>(() => TransactionRemoteDataSource());
  sl.registerLazySingleton<ITransactionRepository>(
        () => TransactionRepositoryImpl(
      local: sl<ITransactionLocalDataSource>(),
      remote: sl<ITransactionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      userIdProvider: sl<UserIdProvider>(),
    ),
  );
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(
        () => AddTransactionUseCase(
      transactionRepository: sl<ITransactionRepository>(),
      balanceRepository: sl<IBalanceRepository>(),
    ),
  );
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerFactory(() => TransactionsBloc(
    getTransactions: sl(),
    addTransaction: sl(),
    deleteTransaction: sl(),
    updateTransaction: sl(),
  ));

  //ANALYTICS
  sl.registerLazySingleton<IAnalyticsRepository>(
        () => AnalyticsRepositoryImpl(
      transactionRepository: sl<ITransactionRepository>(),
      categoryRepository: sl<ICategoryRepository>(),
    ),
  );
  sl.registerLazySingleton(() => GetSpendingSummaryUseCase(sl<IAnalyticsRepository>()));
  sl.registerFactory(() => AnalyticsBloc(getSpendingSummary: sl()));

  //CURRENCY
  sl.registerLazySingleton<ICurrencyLocalDataSource>(() => CurrencyLocalDataSource(sl()));
  sl.registerLazySingleton<ICurrencyRemoteDataSource>(() => CurrencyRemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton<ICurrencyRepository>(
        () => CurrencyRepositoryImpl(
      local: sl<ICurrencyLocalDataSource>(),
      remote: sl<ICurrencyRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton(() => GetExchangeRatesUseCase(sl()));
  sl.registerLazySingleton(() => ConvertCurrencyUseCase(sl()));
  sl.registerFactory(() => CurrencyCubit(
    getExchangeRates: sl(),
    convertCurrency: sl(),
  ));

  // SETTINGS
  sl.registerLazySingleton<ISettingsLocalDataSource>(() => SettingsLocalDataSource(sl()));
  sl.registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl(sl<ISettingsLocalDataSource>()));
  sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveSettingsUseCase(sl()));
  sl.registerFactory(() => SettingsCubit(
    getSettings: sl(),
    saveSettingsUseCase: sl(),
  ));

  // CATEGORIES
  sl.registerLazySingleton<ICategoryLocalDataSource>(() => CategoryLocalDataSource(sl()));
  sl.registerLazySingleton<ICategoryRemoteDataSource>(() => CategoryRemoteDataSource());
  sl.registerLazySingleton<ICategoryRepository>(
        () => CategoryRepositoryImpl(
      local: sl<ICategoryLocalDataSource>(),
      remote: sl<ICategoryRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      userIdProvider: sl<UserIdProvider>(),
    ),
  );
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerFactory(() => CategoriesBloc(
    getCategories: sl(),
    addCategory: sl(),
    updateCategory: sl(),
    deleteCategory: sl(),
  ));
}