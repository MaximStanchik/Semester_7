import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_user.dart';
import '../models/favorite_entry.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;

  ValueListenable<Box<FavoriteEntry>> watchFavorites() => _hiveService.watchFavorites();

  List<Product> getFavoritesForUser(int userId) {
    return _hiveService.getFavoritesForUser(userId);
  }

  bool isFavorite(int userId, Product product) {
    return _hiveService.isFavorite(userId, product);
  }

  Future<void> toggleFavorite(int userId, Product product) async {
    await _hiveService.toggleFavorite(userId, product);
    notifyListeners();
  }
}

