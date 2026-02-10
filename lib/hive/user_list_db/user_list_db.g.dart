// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserListDbAdapter extends TypeAdapter<UserListDb> {
  @override
  final int typeId = 0;

  @override
  UserListDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserListDb(
      usersList: (fields[0] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserListDb obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.usersList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserListDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
