import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/auth/auth_event.dart';
import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/models/user_profile.dart';
import 'package:work_project/repositories/auth_repository.dart';
import 'package:work_project/repositories/user_profile_repository.dart';
import 'package:work_project/screens/auth/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithEmail({required String email, required String password}) {
    throw UnimplementedError();
  }
}

class _FakeUserProfileRepository implements UserProfileRepository {
  @override
  Future<UserProfile> getOrCreateProfile(User user) {
    throw UnimplementedError();
  }

  @override
  Stream<UserProfile> watchProfile(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> upsertProfile(UserProfile profile) {
    throw UnimplementedError();
  }
}

class _TestAuthBloc extends AuthBloc {
  final List<AuthEvent> events = <AuthEvent>[];

  _TestAuthBloc({required AuthState initialState})
      : super(
          authRepo: _FakeAuthRepository(),
          profileRepo: _FakeUserProfileRepository(),
        ) {
    emit(initialState);
  }

  @override
  void add(AuthEvent event) {
    events.add(event);
  }
}

void main() {
  testWidgets('LoginScreen enterText + tap dispatches AuthSignInEmailRequested', (tester) async {
    print('[widget] START: LoginScreen enterText + tap dispatches AuthSignInEmailRequested');
    final authBloc = _TestAuthBloc(initialState: const AuthUnauthenticated());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    print('[widget] Enter email/password and tap Sign in');
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    final signInEvents = authBloc.events.whereType<AuthSignInEmailRequested>().toList();
    expect(signInEvents.length, 1);
    final event = signInEvents.single;
    expect(event.email, 'a@b.com');
    expect(event.password, '123456');

    authBloc.close();
    print('[widget] PASSED: LoginScreen enterText + tap dispatches AuthSignInEmailRequested');
  });

  testWidgets('LoginScreen renders email/password fields and Sign in button', (tester) async {
    print('[widget] START: LoginScreen renders email/password fields and Sign in button');
    final authBloc = _TestAuthBloc(initialState: const AuthUnauthenticated());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);

    authBloc.close();
    print('[widget] PASSED: LoginScreen renders email/password fields and Sign in button');
  });
}
