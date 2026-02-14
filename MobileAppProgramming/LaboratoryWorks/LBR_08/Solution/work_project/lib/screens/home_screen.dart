import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/hive_service.dart';
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
  final HiveService _hiveService = HiveService.instance;
  AppUser? _activeUser;
  bool _isLoading = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final users = _hiveService.getUsers();
    setState(() {
      _activeUser = users.isNotEmpty ? users.first : null;
      _isLoading = false;
    });
  }

  void _onUserSelected(AppUser user) {
    setState(() {
      _activeUser = user;
    });
  }

  Future<void> _showUserSelector() async {
    final users = _hiveService.getUsers();
    final selected = await showModalBottomSheet<AppUser>(
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
                trailing: _activeUser?.id == user.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(user),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      _onUserSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _activeUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      ProductListScreen(activeUser: _activeUser!, hiveService: _hiveService),
      FavoritesScreen(activeUser: _activeUser!, hiveService: _hiveService),
      SecurityToolsScreen(hiveService: _hiveService),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Учет услуг — ${_activeUser!.role}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: _showUserSelector,
            tooltip: 'Сменить пользователя',
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
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
  }

  FloatingActionButton? _buildFab() {
    if (_tabIndex != 0 || _activeUser == null) return null;
    if (!_hiveService.canManageProducts(_activeUser!)) return null;
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductEditScreen(
            hiveService: _hiveService,
          ),
        ),
      ),
      child: const Icon(Icons.add),
    );
  }
}

