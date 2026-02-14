import 'package:flutter/material.dart';
import 'user_provider.dart';
import 'product_provider.dart';
import 'favorite_provider.dart';
import 'history_provider.dart';
import '../models/role.dart';

class AppProvider with ChangeNotifier {
  final UserProvider _userProvider = UserProvider();
  final ProductProvider _productProvider = ProductProvider();
  final FavoriteProvider _favoriteProvider = FavoriteProvider();
  final HistoryProvider _historyProvider = HistoryProvider();

  AppProvider() {
    // Проксируем уведомления от вложенных провайдеров наверх,
    // чтобы Consumer<AppProvider> реагировал на любые изменения.
    _userProvider.addListener(_bubbleNotify);
    _productProvider.addListener(_bubbleNotify);
    _favoriteProvider.addListener(_bubbleNotify);
    _historyProvider.addListener(_bubbleNotify);
  }

  void _bubbleNotify() => notifyListeners();

  UserProvider get userProvider => _userProvider;
  ProductProvider get productProvider => _productProvider;
  FavoriteProvider get favoriteProvider => _favoriteProvider;
  HistoryProvider get historyProvider => _historyProvider;

  // Удобные геттеры для быстрого доступа
  get currentUser => _userProvider.currentUser;
  get users => _userProvider.users;
  get products => _productProvider.products;
  get favorites => _favoriteProvider.favorites;
  get history => _historyProvider.history;

  // Методы для работы с пользователями
  Future<void> setCurrentUser(user) async {
    await _userProvider.setCurrentUser(user);
  }

  Future<void> addUser(user) async {
    await _userProvider.addUser(user);
  }

  Future<void> updateUser(user) async {
    await _userProvider.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await _userProvider.deleteUser(userId);
  }

  // Методы для работы с продуктами
  Future<void> addProduct(product) async {
    await _productProvider.addProduct(product);
  }

  Future<void> updateProduct(product) async {
    await _productProvider.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _productProvider.deleteProduct(productId);
  }

  Future<void> toggleProductLike(String productId) async {
    await _productProvider.toggleProductLike(productId);
  }

  // Методы для работы с избранным
  Future<void> toggleFavorite(String userId, String productId) async {
    await _favoriteProvider.toggleFavorite(userId, productId);
  }

  bool isFavorite(String userId, String productId) {
    return _favoriteProvider.isFavorite(userId, productId);
  }

  // Методы для работы с историей
  Future<void> addSearchHistory(String userId, String query) async {
    await _historyProvider.addSearchHistory(userId, query);
  }

  Future<void> clearUserHistory(String userId) async {
    await _historyProvider.clearUserHistory(userId);
  }

  // Удалить пользователей по роли, с каскадной очисткой связанных данных
  Future<void> deleteUsersByRole(UserRole role) async {
    final usersByRole = _userProvider.getUsersByRole(role);
    for (final u in usersByRole) {
      final favs = _favoriteProvider.getFavoritesByUser(u.id);
      for (final f in favs) {
        await _favoriteProvider.removeFromFavorites(f.userId, f.productId);
      }
      await _historyProvider.clearUserHistory(u.id);
      await _userProvider.deleteUser(u.id);
    }
  }

  @override
  void dispose() {
    _userProvider.removeListener(_bubbleNotify);
    _productProvider.removeListener(_bubbleNotify);
    _favoriteProvider.removeListener(_bubbleNotify);
    _historyProvider.removeListener(_bubbleNotify);
    super.dispose();
  }
}
