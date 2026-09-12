import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/remote/datasources/auth_remote_datasource.dart';
import '../../data/remote/datasources/cart_remote_datasource.dart';
import '../../data/remote/datasources/home_remote_datasource.dart';
import '../../data/remote/datasources/order_remote_datasource.dart';
import '../../data/remote/datasources/profile_remote_datasource.dart';
import '../../data/remote/datasources/tree_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/tree_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/tree_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/send_otp_usecase.dart';
import '../../domain/usecases/auth/verify_otp_usecase.dart';
import '../../domain/usecases/home/get_home_blocks_usecase.dart';
import '../../domain/usecases/cart/add_to_cart_usecase.dart';
import '../../domain/usecases/cart/get_cart_usecase.dart';
import '../../domain/usecases/cart/remove_from_cart_usecase.dart';
import '../../domain/usecases/order/create_order_usecase.dart';
import '../../domain/usecases/order/get_orders_usecase.dart';
import '../../domain/usecases/profile/add_address_usecase.dart';
import '../../domain/usecases/profile/get_addresses_usecase.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import '../../domain/usecases/profile/update_profile_usecase.dart';
import '../../domain/usecases/tree/get_tree_detail_usecase.dart';
import '../../domain/usecases/tree/get_trees_usecase.dart';
import '../../presentation/blocs/auth_bloc.dart';
import '../../presentation/blocs/cart_bloc.dart';
import '../../presentation/blocs/home_bloc.dart';
import '../../presentation/blocs/order_bloc.dart';
import '../../presentation/blocs/otp_bloc.dart';
import '../../presentation/blocs/profile_bloc.dart';
import '../../presentation/blocs/search_bloc.dart';
import '../../presentation/blocs/tree_bloc.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Interceptors
  final dio = sl<Dio>();
  dio.interceptors.add(AuthInterceptor(dio, sl<TokenStorage>()));

  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => TreeRemoteDataSource(sl()));
  sl.registerLazySingleton(() => CartRemoteDataSource(sl()));
  sl.registerLazySingleton(() => OrderRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteDataSource(sl()));
  sl.registerLazySingleton(() => HomeRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<TreeRepository>(() => TreeRepositoryImpl(sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));

  // Usecases
  sl.registerFactory(() => LoginUsecase(sl()));
  sl.registerFactory(() => RegisterUsecase(sl()));
  sl.registerFactory(() => LogoutUsecase(sl()));
  sl.registerFactory(() => GetTreesUsecase(sl()));
  sl.registerFactory(() => GetTreeDetailUsecase(sl()));
  sl.registerFactory(() => GetCartUsecase(sl()));
  sl.registerFactory(() => AddToCartUsecase(sl()));
  sl.registerFactory(() => RemoveFromCartUsecase(sl()));
  sl.registerFactory(() => CreateOrderUsecase(sl()));
  sl.registerFactory(() => GetOrdersUsecase(sl()));
  sl.registerFactory(() => GetProfileUsecase(sl()));
  sl.registerFactory(() => UpdateProfileUsecase(sl()));
  sl.registerFactory(() => GetAddressesUsecase(sl()));
  sl.registerFactory(() => AddAddressUsecase(sl()));
  sl.registerFactory(() => GetHomeBlocksUsecase(sl()));
  sl.registerFactory(() => SendOtpUsecase(sl()));
  sl.registerFactory(() => VerifyOtpUsecase(sl()));

  // BLoCs
  sl.registerFactory(() => AuthBloc(
        login: sl(),
        register: sl(),
        logout: sl(),
        getProfile: sl(),
        tokenStorage: sl(),
      ));
  sl.registerFactory(() => HomeBloc(getHomeBlocks: sl()));
  sl.registerFactory(() => OtpBloc(sendOtp: sl(), verifyOtp: sl()));
  sl.registerFactory(() => CartBloc(getCart: sl(), addToCart: sl(), removeFromCart: sl()));
  sl.registerFactory(() => OrderBloc(getOrders: sl(), createOrder: sl()));
  sl.registerFactory(() => ProfileBloc(getProfile: sl(), updateProfile: sl()));
  sl.registerFactory(() => TreeBloc(getTreeDetail: sl()));
  sl.registerFactory(() => SearchBloc(getTrees: sl()));
}