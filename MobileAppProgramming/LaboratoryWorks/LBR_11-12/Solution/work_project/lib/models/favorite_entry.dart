import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class FavoriteEntry extends HiveObject {
  @HiveField(0)
  final int userId;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final DateTime createdAt;

  FavoriteEntry({
    required this.userId,
    required this.productId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class FavoriteEntryAdapter extends TypeAdapter<FavoriteEntry> {
  @override
  final int typeId = 2;

  @override
  FavoriteEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteEntry(
      userId: fields[0] as int,
      productId: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}

