import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/bloc/auth/auth_event.dart';
import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/repositories/auth_repository.dart';
import 'package:work_project/repositories/user_profile_repository.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<User?> authStateChanges() => super.noSuchMethod(
        Invocation.method(#authStateChanges, []),
        returnValue: const Stream<User?>.empty(),
        returnValueForMissingStub: const Stream<User?>.empty(),
      ) as Stream<User?>;

  @override
  Future<UserCredential> signInWithEmail({required String? email, required String? password}) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmail, [], {#email: email, #password: password}),
        returnValue: Future<UserCredential>.value(MockUserCredential()),
        returnValueForMissingStub: Future<UserCredential>.value(MockUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<UserCredential> signUpWithEmail({required String? email, required String? password}) =>
      super.noSuchMethod(
        Invocation.method(#signUpWithEmail, [], {#email: email, #password: password}),
        returnValue: Future<UserCredential>.value(MockUserCredential()),
        returnValueForMissingStub: Future<UserCredential>.value(MockUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<UserCredential> signInWithGoogle() => super.noSuchMethod(
        Invocation.method(#signInWithGoogle, []),
        returnValue: Future<UserCredential>.value(MockUserCredential()),
        returnValueForMissingStub: Future<UserCredential>.value(MockUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<void> signOut() => super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  group('AuthBloc (unit, Mockito)', () {
    late MockAuthRepository authRepo;
    late MockUserProfileRepository profileRepo;

    setUp(() {
      authRepo = MockAuthRepository();
      profileRepo = MockUserProfileRepository();

      when(authRepo.authStateChanges()).thenAnswer((_) => const Stream<User?>.empty());
    });

    test('AuthSignInEmailRequested emits AuthLoading and calls signInWithEmail', () async {
      final bloc = AuthBloc(authRepo: authRepo, profileRepo: profileRepo);
      when(
        authRepo.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => MockUserCredential());

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignInEmailRequested(email: 'a@b.com', password: '123456'));
      await untilCalled(
        authRepo.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );

      expect(states.whereType<AuthLoading>().length, 1);
      verify(authRepo.signInWithEmail(email: 'a@b.com', password: '123456')).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('AuthSignUpEmailRequested emits AuthLoading and calls signUpWithEmail', () async {
      final bloc = AuthBloc(authRepo: authRepo, profileRepo: profileRepo);
      when(
        authRepo.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => MockUserCredential());

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignUpEmailRequested(email: 'new@b.com', password: '123456'));
      await untilCalled(
        authRepo.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );

      expect(states.whereType<AuthLoading>().length, 1);
      verify(authRepo.signUpWithEmail(email: 'new@b.com', password: '123456')).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('AuthSignInWithGoogleRequested emits AuthLoading and calls signInWithGoogle', () async {
      final bloc = AuthBloc(authRepo: authRepo, profileRepo: profileRepo);
      when(authRepo.signInWithGoogle()).thenAnswer((_) async => MockUserCredential());

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignInWithGoogleRequested());
      await untilCalled(authRepo.signInWithGoogle());

      expect(states.whereType<AuthLoading>().length, 1);
      verify(authRepo.signInWithGoogle()).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('AuthSignOutRequested emits AuthUnauthenticated immediately and calls signOut', () async {
      final bloc = AuthBloc(authRepo: authRepo, profileRepo: profileRepo);
      when(authRepo.signOut()).thenAnswer((_) async {});

      final states = <AuthState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const AuthSignOutRequested());

      await expectLater(bloc.stream, emits(isA<AuthUnauthenticated>()));
      await untilCalled(authRepo.signOut());
      verify(authRepo.signOut()).called(1);

      await sub.cancel();
      await bloc.close();
    });
  });
}
