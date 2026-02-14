import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import 'products/favorites_screen.dart';
import 'products/product_edit_screen.dart';
import 'products/product_list_screen.dart';
import 'products/security_tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  Future<void> _showUserSelector(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final users = userProvider.users;
    final activeUser = userProvider.activeUser;
    
    final selected = await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Выберите пользователя'),
            ),
            ...users.map(
              (user) => ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text('${user.name} (${user.role})'),
                trailing: activeUser?.id == user.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(user),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      userProvider.selectUser(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading || userProvider.activeUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final screens = [
          const ProductListScreen(),
          const FavoritesScreen(),
          const SecurityToolsScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text('Учет услуг — ${userProvider.activeUser!.role}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.switch_account),
                onPressed: () => _showUserSelector(context),
                tooltip: 'Сменить пользователя',
              ),
            ],
          ),
          floatingActionButton: _buildFab(context, userProvider),
          body: IndexedStack(
            index: _tabIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _tabIndex,
            onTap: (value) => setState(() => _tabIndex = value),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Товары'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Безопасность'),
            ],
          ),
        );
      },
    );
  }

  FloatingActionButton? _buildFab(BuildContext context, UserProvider userProvider) {
    if (_tabIndex != 0 || userProvider.activeUser == null) return null;
    if (!userProvider.canManageProducts()) return null;
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProductEditScreen(),
        ),
      ),
      child: const Icon(Icons.add),
    );
  }
}

