class FavoriteItem {
  String userId;
  String productId;
  String? id; // Firestore document ID

  FavoriteItem({required this.userId, required this.productId, this.id});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map, String docId) {
    return FavoriteItem(
      id: docId,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
    );
  }
}


