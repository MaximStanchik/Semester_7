import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailAuthError;
  String? _passwordAuthError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          final code = state.code;

          String? emailError;
          String? passwordError;

          if (code == 'invalid-email' || code == 'user-not-found' || code == 'user-disabled') {
            emailError = state.message;
          } else if (code == 'wrong-password' || code == 'invalid-credential' || code == 'invalid-login-credentials') {
            passwordError = state.message;
          }

          if (emailError != null || passwordError != null) {
            setState(() {
              _emailAuthError = emailError;
              _passwordAuthError = passwordError;
            });
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (_emailAuthError == null) return;
                      setState(() => _emailAuthError = null);
                    },
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  if (_emailAuthError != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _emailAuthError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onChanged: (_) {
                      if (_passwordAuthError == null) return;
                      setState(() => _passwordAuthError = null);
                    },
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  if (_passwordAuthError != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _passwordAuthError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() != true) return;

                        if (_emailAuthError != null || _passwordAuthError != null) {
                          setState(() {
                            _emailAuthError = null;
                            _passwordAuthError = null;
                          });
                        }

                        context.read<AuthBloc>().add(
                              AuthSignInEmailRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                      },
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return const Text('Sign in');
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter email first')),
                        );
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Письмо для сброса пароля отправлено')),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message ?? e.code)),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: const Text('Forgot password?'),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
                      },
                      child: const Text('Sign in with Google'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                      if (result == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Регистрация успешна. Войдите в аккаунт.')),
                        );
                      }
                    },
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
