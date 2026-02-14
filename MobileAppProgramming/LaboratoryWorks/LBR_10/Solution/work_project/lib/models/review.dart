import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final int userId;

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
    return Review(
      id: fields[0] as String,
      productId: fields[1] as String,
      userId: fields[2] as int,
      userName: fields[3] as String,
      rating: fields[4] as int,
      comment: fields[5] as String,
      createdAt: fields[6] as DateTime,
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
