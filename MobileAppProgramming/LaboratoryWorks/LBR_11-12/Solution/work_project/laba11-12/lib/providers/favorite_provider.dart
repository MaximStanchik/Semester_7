import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite.dart';
import '../services/firebase_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteItem> _favorites = [];
  final CollectionReference _favoritesCollection = FirebaseService.firestore.collection('favorites');

  List<FavoriteItem> get favorites => _favorites;

  FavoriteProvider() {
    _subscribeToFavorites();
  }

  void _subscribeToFavorites() {
    _favoritesCollection.snapshots().listen((snapshot) {
      _favorites = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FavoriteItem.fromMap(data, doc.id);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addToFavorites(String userId, String productId) async {
    // Check if already exists
    final existing = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _favoritesCollection.add({
        'userId': userId,
        'productId': productId,
      });
    }
    // Data will be updated via snapshot listener
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    final favorites = await _favoritesCollection
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    for (var doc in favorites.docs) {
      await doc.reference.delete();
    }
    // Data will be updated via snapshot listener
  }

  bool isFavorite(String userId, String productId) {
    return _favorites.any((fav) => fav.userId == userId && fav.productId == productId);
  }

  List<FavoriteItem> getFavoritesByUser(String userId) {
    return _favorites.where((fav) => fav.userId == userId).toList();
  }

  Future<void> toggleFavorite(String userId, String productId) async {
    if (isFavorite(userId, productId)) {
      await removeFromFavorites(userId, productId);
    } else {
      await addToFavorites(userId, productId);
    }
  }
}
