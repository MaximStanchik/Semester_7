import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/employee/employee_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductBloc()),
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => FavoritesBloc()),
        BlocProvider(create: (_) => EmployeeBloc()),
      ],
      child: MaterialApp(
        title: 'Учет услуг',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
