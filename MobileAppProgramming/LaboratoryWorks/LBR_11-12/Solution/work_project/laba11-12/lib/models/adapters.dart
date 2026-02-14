import 'package:hive/hive.dart';

import 'role.dart';
import 'user.dart';
import 'product.dart';
import 'favorite.dart';
import 'history.dart';

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    final index = reader.readByte();
    return UserRole.values[index];
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    writer.writeByte(obj.index);
  }
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 1;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as UserRole,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role);
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 2;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Product(
      id: fields[0] as String,
      title: fields[1] as String,
      imagePath: fields[2] as String,
      price: (fields[3] as num).toDouble(),
      location: fields[4] as String,
      reviewsCount: fields[5] as int,
      description: fields[6] as String,
      liked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.liked);
  }
}

class FavoriteItemAdapter extends TypeAdapter<FavoriteItem> {
  @override
  final int typeId = 3;

  @override
  FavoriteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FavoriteItem(
      userId: fields[0] as String,
      productId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.productId);
  }
}

class SearchHistoryAdapter extends TypeAdapter<SearchHistory> {
  @override
  final int typeId = 4;

  @override
  SearchHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SearchHistory(
      id: fields[0] as String,
      userId: fields[1] as String,
      query: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.query)
      ..writeByte(3)
      ..write(obj.createdAt);
  }
}


