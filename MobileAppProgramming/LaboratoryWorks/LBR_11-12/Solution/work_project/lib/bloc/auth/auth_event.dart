import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSendPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthSendPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
