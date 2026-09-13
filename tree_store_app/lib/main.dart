import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection.dart' as di;
import 'core/network/token_storage.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/cart_bloc.dart';
import 'presentation/blocs/home_bloc.dart';
import 'presentation/blocs/order_bloc.dart';
import 'presentation/blocs/otp_bloc.dart';
import 'presentation/blocs/profile_bloc.dart';
import 'presentation/blocs/search_bloc.dart';
import 'presentation/blocs/tree_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await di.initDependencies();
  runApp(const VerdantApp());
}

class VerdantApp extends StatelessWidget {
  const VerdantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const AuthCheckToken()),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => di.sl<HomeBloc>(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => di.sl<CartBloc>(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => di.sl<OrderBloc>(),
        ),
        BlocProvider<OtpBloc>(
          create: (_) => di.sl<OtpBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>(),
        ),
        BlocProvider<TreeBloc>(
          create: (_) => di.sl<TreeBloc>(),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => di.sl<SearchBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Verdant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: createRouter(di.sl<TokenStorage>()),
      ),
    );
  }
}