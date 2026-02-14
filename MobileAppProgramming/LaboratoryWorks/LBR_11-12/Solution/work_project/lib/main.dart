import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'services/remote_config_service.dart';
import 'bloc/product/product_bloc.dart';
import 'bloc/favorites/favorites_bloc.dart';
import 'bloc/employee/employee_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.instance.init();

  Object? firebaseInitError;
  try {
    await Firebase.initializeApp();
    if (!kDebugMode) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    await RemoteConfigService.instance.init();
    await NotificationService.instance.init();
  } catch (e) {
    firebaseInitError = e;
  }

  runApp(MyApp(firebaseInitError: firebaseInitError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseInitError;

  const MyApp({super.key, required this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProductBloc()),
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
        home: firebaseInitError == null
            ? const AuthGate()
            : FirebaseInitErrorScreen(error: firebaseInitError!),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        if (state is AuthUnauthenticated) {
          return const LoginScreen();
        }
        if (state is AuthError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Auth error')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(state.message),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class FirebaseInitErrorScreen extends StatelessWidget {
  final Object error;

  const FirebaseInitErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase init error')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(error.toString()),
      ),
    );
  }
}
