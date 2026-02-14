import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => curr is AuthError,
          listener: (context, state) {
            if (state is AuthError) {
              final code = state.code;

              String? emailError;
              String? passwordError;

              if (code == 'invalid-email' || code == 'email-already-in-use' || code == 'operation-not-allowed') {
                emailError = state.message;
              } else if (code == 'weak-password' || code == 'invalid-credential' || code == 'invalid-login-credentials') {
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
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => curr is AuthAuthenticated && prev is! AuthAuthenticated,
          listener: (context, state) {
            context.read<AuthBloc>().add(const AuthSignOutRequested());
            Navigator.pop(context, true);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 6) return 'Min 6 chars';
                      return null;
                    },
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
                              AuthSignUpEmailRequested(
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
                          return const Text('Create');
                        },
                      ),
                    ),
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
