import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/role.dart';
import 'favorites_page.dart';
import 'products_page.dart';

class UserDashboardPage extends StatelessWidget {
  final AppUser currentUser;
  const UserDashboardPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isRegularUser = currentUser.role == UserRole.user;
    return Scaffold(
      appBar: AppBar(title: Text('Профиль: ${currentUser.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductsPage(currentUser: currentUser),
                  ),
                );
              },
              child: const Text('Управление поездками'),
            ),
            const SizedBox(height: 12),
            if (isRegularUser)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritesPage(currentUser: currentUser),
                    ),
                  );
                },
                child: const Text('Моё избранное'),
              ),
          ],
        ),
      ),
    );
  }
}


