import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class FirestoreProductRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _firestore.collection('products');

  Future<List<Product>> fetchAll() async {
    final snapshot = await _col.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(growable: false);
  }

  Stream<List<Product>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList(growable: false),
        );
  }

  Future<void> upsert(Product product) async {
    await _col.doc(product.id).set(product.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteById(String productId) async {
    await _col.doc(productId).delete();
  }

  Future<void> toggleLike(String productId) async {
    final ref = _col.doc(productId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data();
      final current = (data?['isLiked'] as bool?) ?? false;
      tx.update(ref, {'isLiked': !current});
    });
  }

  Future<void> incrementReviewsCount(String productId, int delta) async {
    await _col.doc(productId).update({'reviewsCount': FieldValue.increment(delta)});
  }
}
