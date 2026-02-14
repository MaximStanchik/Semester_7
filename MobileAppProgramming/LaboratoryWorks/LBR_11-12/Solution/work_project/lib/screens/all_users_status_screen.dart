import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class AllUsersStatusScreen extends StatelessWidget {
  const AllUsersStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    const databaseUrl = 'https://lbr11-12-default-rtdb.europe-west1.firebasedatabase.app';
    final statusStream = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    ).ref('status').onValue;

    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи (online/offline)')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: usersStream,
        builder: (context, usersSnapshot) {
          if (usersSnapshot.hasError) {
            return Center(child: Text('Ошибка users: ${usersSnapshot.error}'));
          }
          if (!usersSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final usersDocs = usersSnapshot.data!.docs;
          final users = usersDocs
              .map((d) {
                final data = d.data();
                return UserProfile.fromJson({
                  ...data,
                  'uid': data['uid'] ?? d.id,
                });
              })
              .toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return StreamBuilder<DatabaseEvent>(
            stream: statusStream,
            builder: (context, statusSnapshot) {
              final statusValue = statusSnapshot.data?.snapshot.value;
              final statusMap = statusValue is Map ? statusValue.cast<String, dynamic>() : <String, dynamic>{};

              if (users.isEmpty) {
                return const Center(child: Text('Пользователей нет.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final raw = statusMap[user.uid];
                  final data = raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};

                  final online = (data['online'] as bool?) ?? false;
                  final lastActiveRaw = data['lastActive'];
                  DateTime? lastActive;
                  if (lastActiveRaw is num) {
                    lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveRaw.toInt());
                  }

                  final subtitleLines = <String>[
                    if (user.email != null) user.email!,
                    'Роль: ${user.role}',
                    online
                        ? 'Последняя активность: только что'
                        : lastActive == null
                            ? 'Последняя активность: нет данных'
                            : 'Последняя активность: ${lastActive.toLocal()}',
                  ];

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        online ? Icons.circle : Icons.circle_outlined,
                        color: online ? Colors.green : Colors.grey,
                      ),
                      title: Text(user.name.isEmpty ? user.uid : user.name),
                      subtitle: Text(subtitleLines.join('\n')),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
