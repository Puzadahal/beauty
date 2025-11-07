import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme_data.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/local_storage_service.dart';
import 'firebase_options.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'presentation/bloc/products/products_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  final localStorageService = LocalStorageService(sharedPreferences);
  final apiService = ApiService();
  final authService = FirebaseAuthService(
    localStorageService: localStorageService,
  );

  runApp(
    MyApp(
      apiService: apiService,
      authService: authService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.apiService,
    required this.authService,
  });

  final ApiService apiService;
  final FirebaseAuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductsBloc(apiService: apiService)
            ..add(const LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: authService)..add(const CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => OrdersBloc(
            apiService: apiService,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Beauty & Cosmetics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
