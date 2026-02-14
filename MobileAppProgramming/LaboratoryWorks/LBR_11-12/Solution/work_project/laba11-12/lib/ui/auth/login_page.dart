import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../bloc/app_bloc.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../providers/app_provider.dart';
import '../../models/user.dart';
import '../../models/role.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (credential?.user != null) {
        // Get or create user in Firestore
        final userProvider = context.read<AppProvider>().userProvider;
        var appUser = await userProvider.getUserByFirebaseId(credential!.user!.uid);
        
        if (appUser == null) {
          // Create user if doesn't exist
          appUser = AppUser(
            id: credential.user!.uid,
            name: credential.user!.displayName ?? credential.user!.email!.split('@')[0],
            role: UserRole.user,
            email: credential.user!.email,
            photoUrl: credential.user!.photoURL,
          );
          await userProvider.addUser(appUser);
        }

        // Set current user and update status
        await userProvider.setCurrentUser(appUser);
        context.read<AppBloc>().add(SetCurrentUser(appUser));

        // Track login event
        FirebaseService.analytics.logLogin(loginMethod: 'email');

        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _authService.signInWithGoogle();
      
      if (credential?.user != null) {
        final userProvider = context.read<AppProvider>().userProvider;
        var appUser = await userProvider.getUserByFirebaseId(credential!.user!.uid);
        
        if (appUser == null) {
          appUser = AppUser(
            id: credential.user!.uid,
            name: credential.user!.displayName ?? 'User',
            role: UserRole.user,
            email: credential.user!.email,
            photoUrl: credential.user!.photoURL,
          );
          await userProvider.addUser(appUser);
        }

        await userProvider.setCurrentUser(appUser);
        context.read<AppBloc>().add(SetCurrentUser(appUser));

        // Track login event
        FirebaseService.analytics.logLogin(loginMethod: 'google');

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Добро пожаловать',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                    );
                  },
                  child: const Text('Забыли пароль?'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Войти'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata, size: 32),
                label: const Text('Войти через Google'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text('Зарегистрироваться'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

