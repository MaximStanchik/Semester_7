import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class FirestoreFavoritesRepository {
  final FirebaseFirestore _firestore;

  FirestoreFavoritesRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favoritesCol(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  Stream<Set<String>> watchFavoriteProductIds(String userId) {
    return _favoritesCol(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => d.id).toSet(),
        );
  }

  Future<void> toggleFavorite({
    required String userId,
    required String productId,
  }) async {
    final doc = _favoritesCol(userId).doc(productId);
    final snap = await doc.get();
    if (snap.exists) {
      await doc.delete();
    } else {
      await doc.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Future<bool> isFavorite({
    required String userId,
    required String productId,
  }) async {
    final snap = await _favoritesCol(userId).doc(productId).get();
    return snap.exists;
  }

  Future<List<Product>> fetchFavoritesProducts({
    required String userId,
  }) async {
    final favSnap = await _favoritesCol(userId).get();
    final ids = favSnap.docs.map((d) => d.id).toList(growable: false);
    if (ids.isEmpty) return const <Product>[];

    final productsCol = _firestore.collection('products');
    final results = <Product>[];

    const chunkSize = 10;
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, (i + chunkSize) > ids.length ? ids.length : (i + chunkSize));
      final productsSnap = await productsCol
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(productsSnap.docs.map((d) => Product.fromFirestore(d)));
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }
}
