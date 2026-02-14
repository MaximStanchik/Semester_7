import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/auth/auth_event.dart';
import 'package:work_project/screens/auth/register_screen.dart';

import 'package:work_project/models/user_profile.dart';
import 'package:work_project/repositories/auth_repository.dart';
import 'package:work_project/repositories/user_profile_repository.dart';

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

class TestAuthBloc extends AuthBloc {
  final List<AuthEvent> events = <AuthEvent>[];

  TestAuthBloc()
      : super(
          authRepo: _FakeAuthRepository(),
          profileRepo: _FakeUserProfileRepository(),
        );

  @override
  void add(AuthEvent event) {
    events.add(event);
  }
}

void main() {
  testWidgets('RegisterScreen enterText + tap dispatches AuthSignUpEmailRequested', (tester) async {
    print('[widget] START: RegisterScreen enterText + tap dispatches AuthSignUpEmailRequested');
    final authBloc = TestAuthBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const RegisterScreen(),
        ),
      ),
    );

    print('[widget] Enter email/password and tap Create');
    await tester.enterText(find.byType(TextFormField).at(0), 'new@b.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Create'));
    await tester.pump();

    final signUpEvents = authBloc.events.whereType<AuthSignUpEmailRequested>().toList();
    expect(signUpEvents.length, 1);
    final event = signUpEvents.single;
    expect(event.email, 'new@b.com');
    expect(event.password, '123456');

    authBloc.close();
    print('[widget] PASSED: RegisterScreen enterText + tap dispatches AuthSignUpEmailRequested');
  });

  testWidgets('RegisterScreen renders email/password fields and Create button', (tester) async {
    print('[widget] START: RegisterScreen renders email/password fields and Create button');
    final authBloc = TestAuthBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const RegisterScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Create'), findsOneWidget);

    authBloc.close();
    print('[widget] PASSED: RegisterScreen renders email/password fields and Create button');
  });
}
