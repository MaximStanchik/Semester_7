import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String userName;

  @HiveField(4)
  final int rating; // 1-5

  @HiveField(5)
  final String comment;

  @HiveField(6)
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toFirestore({
    required String productId,
  }) {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory Review.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String productId,
  }) {
    final data = doc.data();
    if (data == null) {
      return Review(
        id: doc.id,
        productId: productId,
        userId: '',
        userName: '',
        rating: 0,
        comment: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }

    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Review(
      id: (data['id'] as String?) ?? doc.id,
      productId: (data['productId'] as String?) ?? productId,
      userId: (data['userId'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: (data['comment'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}

class ReviewAdapter extends TypeAdapter<Review> {
  @override
  final int typeId = 3;

  @override
  Review read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final userIdRaw = fields[2];
    final userId = userIdRaw is String
        ? userIdRaw
        : userIdRaw is num
            ? userIdRaw.toInt().toString()
            : '';

    final createdAtRaw = fields[6];
    final createdAt = createdAtRaw is DateTime ? createdAtRaw : DateTime.now();

    return Review(
      id: fields[0] as String,
      productId: fields[1] as String,
      userId: userId,
      userName: fields[3] as String,
      rating: fields[4] as int,
      comment: fields[5] as String,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, Review obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
