import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class CurrentUserScreen extends StatelessWidget {
  const CurrentUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Текущий пользователь')),
            body: const Center(child: Text('Пользователь не авторизован')),
          );
        }

        final profile = state.profile;
        const databaseUrl = 'https://lbr11-12-default-rtdb.europe-west1.firebasedatabase.app';
        DatabaseReference? ref;
        try {
          ref = FirebaseDatabase.instanceFor(
            app: Firebase.app(),
            databaseURL: databaseUrl,
          ).ref('status/${profile.uid}');
        } catch (_) {
          ref = null;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Текущий пользователь')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UID: ${profile.uid}'),
                      const SizedBox(height: 8),
                      Text('Email: ${profile.email}'),
                      const SizedBox(height: 8),
                      Text('Имя: ${profile.name}'),
                      const SizedBox(height: 8),
                      Text('Роль: ${profile.role}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (ref == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Статус: недоступен'),
                  ),
                )
              else
                StreamBuilder<DatabaseEvent>(
                  stream: ref.onValue,
                  builder: (context, snapshot) {
                    final value = snapshot.data?.snapshot.value;
                    final data = value is Map ? value.cast<String, dynamic>() : <String, dynamic>{};

                    final online = (data['online'] as bool?) ?? false;
                    final lastActiveRaw = data['lastActive'];
                    DateTime? lastActive;
                    if (lastActiveRaw is num) {
                      lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveRaw.toInt());
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              online ? 'Статус: online' : 'Статус: offline',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: online ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              online
                                  ? 'Последняя активность: только что'
                                  : lastActive == null
                                      ? 'Последняя активность: нет данных'
                                      : 'Последняя активность: ${lastActive.toLocal()}',
                            ),
                            if (snapshot.hasError) ...[
                              const SizedBox(height: 8),
                              Text('Ошибка: ${snapshot.error}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
