import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import 'employee_list_screen.dart';
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

  String? _favoritesLoadedForUid;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }

        if (_favoritesLoadedForUid != state.profile.uid) {
          _favoritesLoadedForUid = state.profile.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<FavoritesBloc>().add(FavoritesLoadRequested(state.profile.uid));
          });
        }

        final screens = [
          const ProductListScreen(),
          const FavoritesScreen(),
          const SecurityToolsScreen(),
          const EmployeeListScreen(),
        ];

        return Scaffold(
          floatingActionButton: _buildFab(context, state),
          body: Stack(
            children: [
              IndexedStack(
                index: _tabIndex,
                children: screens,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.logout, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(context, Icons.store, 0, 'Товары'),
                _buildBottomNavItem(context, Icons.favorite, 1, 'Избранное'),
                _buildBottomNavItem(context, Icons.lock, 2, 'Безопасность'),
                _buildBottomNavItem(context, Icons.people, 3, 'Сотрудники'),
              ],
            ),
          ),
        );
      },
    );
  }

  FloatingActionButton? _buildFab(BuildContext context, AuthAuthenticated state) {
    if (_tabIndex != 0) return null;
    return FloatingActionButton(
      heroTag: 'home_add_product_fab',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProductEditScreen(),
        ),
      ),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, int index, String label) {
    final isSelected = _tabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }
}

