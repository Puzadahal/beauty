import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme_data.dart';
import 'core/router/app_router.dart';
import 'presentation/bloc/products/products_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'data/services/api_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductsBloc(apiService: ApiService())
            ..add(const LoadProducts()),
        ),
        BlocProvider(
          create: (context) => CartBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc()..add(const CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => OrdersBloc(
            apiService: ApiService(),
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
