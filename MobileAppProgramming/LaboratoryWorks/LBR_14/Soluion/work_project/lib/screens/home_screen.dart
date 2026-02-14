import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../models/app_user.dart';
import '../utils/animations.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int? _pendingTabSnackIndex;
  bool _userButtonPressed = false;
  late final AnimationController _userRotateController;
  late final Animation<double> _userRotateTurns;

  @override
  void initState() {
    super.initState();
    _userRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _userRotateTurns = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _userRotateController, curve: Curves.easeOutCubic),
    );
    _userRotateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _userRotateController.reset();
      }
    });
  }

  @override
  void dispose() {
    _userRotateController.dispose();
    super.dispose();
  }

  Future<void> _showUserSelector(BuildContext context) async {
    final userBloc = context.read<UserBloc>();
    final state = userBloc.state;
    
    if (state is! UserLoaded) return;
    
    final users = state.users;
    final activeUser = state.activeUser;
    
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
                trailing: activeUser?.id == user.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(user),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      userBloc.add(UserSelected(selected));
      // Load favorites for the new user
      context.read<FavoritesBloc>().add(FavoritesLoadRequested(selected.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! UserLoaded || state.activeUser == null) {
          return const Scaffold(
            body: Center(child: Text('Ошибка загрузки пользователя')),
          );
        }

        final screens = [
          const ProductListScreen(),
          const FavoritesScreen(),
          const SecurityToolsScreen(),
          const EmployeeListScreen(),
        ];
        final tabChildren = List<Widget>.generate(
          screens.length,
          (i) => TickerMode(
            enabled: _tabIndex == i,
            child: screens[i],
          ),
        );

        return Scaffold(
          floatingActionButton: _buildFab(context, state),
          body: Stack(
            children: [
              IndexedStack(
                index: _tabIndex,
                children: tabChildren,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () async {
                        if (_userButtonPressed) return;
                        _userRotateController.forward(from: 0);
                        setState(() => _userButtonPressed = true);
                        await _showUserSelector(context);
                        if (!mounted) return;
                        setState(() => _userButtonPressed = false);
                      },
                      child: AnimatedScale(
                        scale: _userButtonPressed ? 0.94 : 1,
                        duration: const Duration(milliseconds: 220),
                        curve: const SinInCurve(),
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
                          child: RotationTransition(
                            turns: _userRotateTurns,
                            child: const Icon(Icons.switch_account, color: Colors.black),
                          ),
                        ),
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

  FloatingActionButton? _buildFab(BuildContext context, UserLoaded state) {
    if (_tabIndex != 0 || state.activeUser == null) return null;
    if (!state.canManageProducts) return null;
    return FloatingActionButton(
      heroTag: 'home_add_product_fab',
      onPressed: () => Navigator.push(
        context,
        buildScaleFadeRoute(builder: (_) => const ProductEditScreen()),
      ),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, int index, String label) {
    final isSelected = _tabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabIndex = index;
          _pendingTabSnackIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: const SinInCurve(),
        onEnd: () {
          if (!mounted) return;
          if (_pendingTabSnackIndex != index) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Открыта вкладка: $label'),
              duration: const Duration(milliseconds: 900),
            ),
          );
          setState(() => _pendingTabSnackIndex = null);
        },
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isSelected ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 24,
          ),
          builder: (context, t, child) {
            return Transform.scale(
              scale: 1.0 + (0.16 * t),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
