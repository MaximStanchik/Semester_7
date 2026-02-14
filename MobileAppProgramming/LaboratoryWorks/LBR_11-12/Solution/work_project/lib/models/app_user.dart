import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as int,
      name: fields[1] as String,
      role: fields[2] as String,
      avatarUrl: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.avatarUrl);
  }
}
