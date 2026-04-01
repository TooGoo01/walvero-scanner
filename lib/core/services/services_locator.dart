
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walveroScanner/data/data_sources/local/user_local_data_source.dart';
import 'package:walveroScanner/data/data_sources/remote/redeem_remote_data_source.dart';
import 'package:walveroScanner/data/data_sources/remote/customer_remote_data_source.dart';
import 'package:walveroScanner/data/data_sources/remote/statistics_remote_data_source.dart';
import 'package:walveroScanner/data/data_sources/remote/user_remote_data_source.dart';
import 'package:walveroScanner/data/repositories/customer_repository_impl.dart';
import 'package:walveroScanner/data/repositories/redeem_repository_impl.dart' show RedeemRepositoryImpl;
import 'package:walveroScanner/data/repositories/statistics_repository_impl.dart';
import 'package:walveroScanner/data/repositories/user_repository_impl.dart';
import 'package:walveroScanner/domain/repositories/customer_repository.dart';
import 'package:walveroScanner/domain/repositories/redeem_repository.dart' show RedeemRepository;
import 'package:walveroScanner/domain/repositories/statistics_repository.dart';
import 'package:walveroScanner/domain/repositories/user_repository.dart';

import '../../domain/usecases/redeem/get_lookup_bycode_usecase.dart';
import '../../domain/usecases/redeem/get_remote_uiconfig_usecase.dart';
import '../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../../domain/usecases/customer/get_customers_usecase.dart';
import '../../domain/usecases/customer/get_customer_transactions_usecase.dart';
import '../../domain/usecases/customer/reverse_transaction_usecase.dart';
import '../../domain/usecases/statistics/get_dashboard_statistics_usecase.dart';
import '../../domain/usecases/user/get_local_user_usecase.dart';
import '../../domain/usecases/user/sign_in_usecase.dart';
import '../../domain/usecases/user/refresh_token_usecase.dart';
import '../../domain/usecases/user/sign_out_usecase.dart';
import '../../domain/usecases/user/sign_up_usecase.dart';

import '../../presentation/blocs/customer/customer_bloc.dart';
import '../../presentation/blocs/redeem/redeem_bloc.dart';
import '../../presentation/blocs/statistics/statistics_bloc.dart';
import '../../presentation/blocs/user/user_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Features - Product
  // Bloc
  

  sl.registerFactory(
  () => RedeemBloc(
    sl(),
    sl(),
    sl(),

    sl(),

  ),
);
  // Use cases
  sl.registerLazySingleton(() => GetRemoteUiconfigUsecase(sl()));
  sl.registerLazySingleton(() => GetLookupUseCase(sl()));
  sl.registerLazySingleton(() => StartRedeemUseCase(sl()));
sl.registerLazySingleton(() => ConfirmRedeemOtpUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RedeemRepository>(
    () => RedeemRepositoryImpl(
      remoteDataSource: sl(),
      userLocalDataSource: sl(),
      userRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<RedeemRemoteDataSource>(
    () => RedeemRemoteDataSourceImpl(client: sl()),
  );

  //Features - Statistics
  // Bloc
  sl.registerFactory(
    () => StatisticsBloc(sl()),
  );
  // Use cases
  sl.registerLazySingleton(() => GetDashboardStatisticsUseCase(sl()));
  // Repository
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(
      remoteDataSource: sl(),
      userLocalDataSource: sl(),
      userRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(client: sl()),
  );

  //Features - Customer
  // Bloc
  sl.registerFactory(
    () => CustomerBloc(sl(), sl(), sl()),
  );
  // Use cases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => ReverseTransactionUseCase(sl()));
  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: sl(),
      userLocalDataSource: sl(),
      userRemoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(client: sl()),
  );

  
 

  
 
 

  //Features - User
  // Bloc
  sl.registerFactory(
    () => UserBloc(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  // Use cases
  sl.registerLazySingleton(() => GetLocalUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  ///***********************************************
  ///! Core
  /// sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  ///! External
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => secureStorage);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}