import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

import 'package:work_project/bloc/auth/auth_state.dart';
import 'package:work_project/bloc/auth/auth_bloc.dart';
import 'package:work_project/models/user_profile.dart';
import 'package:work_project/screens/current_user_screen.dart';

import 'test_utils/test_blocs.dart';

class _TestBanner extends StatelessWidget {
  final String text;

  const _TestBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Material(
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  testWidgets('Current user screen shows profile fields', (tester) async {
    print('[integration] START: current_user_info_test');
    final authBloc = TestAuthBloc(
      initialState: const AuthAuthenticated(
        profile: UserProfile(uid: 'u1', name: 'User', role: 'viewer', email: 'u@e.com'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: Stack(
            children: [
              const CurrentUserScreen(),
              const _TestBanner(text: 'RUNNING: Current user info'),
            ],
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('UID: u1'), findsOneWidget);
    expect(find.textContaining('Email: u@e.com'), findsOneWidget);
    expect(find.textContaining('Имя: User'), findsOneWidget);
    expect(find.textContaining('Роль: viewer'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(),
              _TestBanner(text: 'PASSED: Current user info'),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    print('[integration] PASSED: current_user_info_test');

    await authBloc.close();
  });
}
