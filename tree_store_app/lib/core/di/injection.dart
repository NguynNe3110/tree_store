import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/remote/datasources/auth_remote_datasource.dart';
import '../../data/remote/datasources/order_remote_datasource.dart';
import '../../data/remote/datasources/profile_remote_datasource.dart';
import '../../data/remote/datasources/tree_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/tree_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/tree_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/order/create_order_usecase.dart';
import '../../domain/usecases/order/get_orders_usecase.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import '../../domain/usecases/profile/update_profile_usecase.dart';
import '../../domain/usecases/tree/get_tree_detail_usecase.dart';
import '../../domain/usecases/tree/get_trees_usecase.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => TreeRemoteDataSource(sl()));
  sl.registerLazySingleton(() => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<TreeRepository>(() => TreeRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));

  // Usecases
  sl.registerFactory(() => LoginUsecase(sl()));
  sl.registerFactory(() => RegisterUsecase(sl()));
  sl.registerFactory(() => LogoutUsecase(sl()));
  sl.registerFactory(() => GetTreesUsecase(sl()));
  sl.registerFactory(() => GetTreeDetailUsecase(sl()));
  sl.registerFactory(() => CreateOrderUsecase(sl()));
  sl.registerFactory(() => GetOrdersUsecase(sl()));
  sl.registerFactory(() => GetProfileUsecase(sl()));
  sl.registerFactory(() => UpdateProfileUsecase(sl()));
}