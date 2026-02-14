import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

class FirestoreReviewsRepository {
  final FirebaseFirestore _firestore;

  FirestoreReviewsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _reviewsCol(String productId) {
    return _firestore.collection('products').doc(productId).collection('reviews');
  }

  Stream<List<Review>> watchReviewsForProduct(String productId) {
    return _reviewsCol(productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => Review.fromFirestore(d, productId: productId))
              .toList(growable: false),
        );
  }

  Future<void> addReview({
    required String productId,
    required Review review,
  }) async {
    final doc = _reviewsCol(productId).doc(review.id);
    await doc.set(review.toFirestore(productId: productId));
  }
}
