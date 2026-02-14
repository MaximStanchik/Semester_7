import 'package:equatable/equatable.dart';

import '../../models/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final UserProfile profile;

  const AuthAuthenticated({
    required this.profile,
  });

  bool get canManageProducts => profile.role == 'admin' || profile.role == 'manager';

  @override
  List<Object?> get props => [profile];
}

class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
