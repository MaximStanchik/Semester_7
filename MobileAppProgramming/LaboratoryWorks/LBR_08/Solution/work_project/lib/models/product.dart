import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final int reviewsCount;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final bool isLiked;

  @HiveField(8)
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.location,
    required this.reviewsCount,
    required this.description,
    this.isLiked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Product copyWith({
    String? id,
    String? title,
    String? imagePath,
    double? price,
    String? location,
    int? reviewsCount,
    String? description,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      location: location ?? this.location,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      description: description ?? this.description,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      title: fields[1] as String,
      imagePath: fields[2] as String,
      price: fields[3] as double,
      location: fields[4] as String,
      reviewsCount: fields[5] as int,
      description: fields[6] as String,
      isLiked: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.reviewsCount)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.isLiked)
      ..writeByte(8)
      ..write(obj.createdAt);
  }
}

