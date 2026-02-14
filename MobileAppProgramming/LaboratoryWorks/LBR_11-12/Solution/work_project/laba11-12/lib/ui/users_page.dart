import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../bloc/app_bloc.dart';

class UsersPage extends StatefulWidget {
  final void Function(AppUser) onSelect;
  const UsersPage({super.key, required this.onSelect});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    _initializeDefaultUsers();
  }

  Future<void> _initializeDefaultUsers() async {
    context.read<AppBloc>().add(
      EnsureDefaultUsers([
        AppUser(id: '1', name: 'Админ', role: UserRole.admin),
        AppUser(id: '2', name: 'Менеджер', role: UserRole.manager),
        AppUser(id: '3', name: 'Пользователь', role: UserRole.user),
      ]),
    );
  }

  Future<void> _addUser() async {
    final controller = TextEditingController();
    UserRole role = UserRole.user;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Новый пользователь'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Имя')),
            const SizedBox(height: 8),
            DropdownButton<UserRole>(
              value: role,
              items: UserRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  role = v;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () async {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              context.read<AppBloc>().add(AddUserEvent(AppUser(id: id, name: controller.text.trim(), role: role)));
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final users = state.users;
        return Scaffold(
          appBar: AppBar(title: const Text('Пользователи')),
          floatingActionButton: FloatingActionButton(onPressed: _addUser, child: const Icon(Icons.add)),
          body: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final u = users[i];
              return ListTile(
                title: Text(u.name),
                subtitle: Text('Роль: ${u.role.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Удалить всех с ролью',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Удалить пользователей роли?'),
                        content: Text('Будут удалены все пользователи с ролью "${u.role.name}", их избранное и история.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dctx, false), child: const Text('Отмена')),
                          ElevatedButton(onPressed: () => Navigator.pop(dctx, true), child: const Text('Удалить')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      context.read<AppBloc>().add(DeleteUsersByRoleEvent(u.role));
                    }
                  },
                ),
                onTap: () => widget.onSelect(u),
              );
            },
          ),
        );
      },
    );
  }
}


