import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/user_status_service.dart';
import '../services/firebase_service.dart';
import '../bloc/app_bloc.dart';
import '../providers/app_provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _userStatusService = UserStatusService();
  final _authService = AuthService();
  Map<String, dynamic>? _userStatus;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    final state = context.read<AppBloc>().state;
    if (state.currentUser != null) {
      final status = await _userStatusService.getUserStatus(state.currentUser!.id);
      if (mounted) {
        setState(() {
          _userStatus = status;
        });
      }

      // Subscribe to status updates
      _userStatusService.getUserStatusStream(state.currentUser!.id).listen((status) {
        if (mounted) {
          setState(() {
            _userStatus = status;
          });
        }
      });
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Неизвестно';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} минут назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} часов назад';
    } else {
      return '${difference.inDays} дней назад';
    }
  }

  Future<void> _handleSignOut() async {
    final appBloc = context.read<AppBloc>();
    final userId = appBloc.state.currentUser?.id;

    appBloc.add(SetCurrentUser(null));
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }

    () async {
      try {
        if (userId != null) {
          await _userStatusService.setUserOffline(userId);
        }
      } catch (_) {}

      try {
        await _authService.signOut();
      } catch (_) {}
    }();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final user = state.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Пользователь не авторизован')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleSignOut,
                tooltip: 'Выйти',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 48),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Имя', user.name),
                        const Divider(),
                        if (user.email != null) ...[
                          _buildInfoRow('Email', user.email!),
                          const Divider(),
                        ],
                        _buildInfoRow('Роль', user.role.name),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статус',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _userStatus?['status'] == 'online'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _userStatus?['status'] == 'online' ? 'Онлайн' : 'Офлайн',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Последняя активность: ${_formatTimestamp(_userStatus?['lastSeen'] as int?)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Статистика',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          'Избранное',
                          '${state.favorites.where((f) => f.userId == user.id).length}',
                          Icons.favorite,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'История поиска',
                          '${state.history.where((h) => h.userId == user.id).length}',
                          Icons.history,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

