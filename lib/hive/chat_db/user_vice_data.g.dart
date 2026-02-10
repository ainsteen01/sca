// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vice_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserViceDataAdapter extends TypeAdapter<UserViceData> {
  @override
  final int typeId = 1;

  @override
  UserViceData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserViceData(
      messages: (fields[0] as List).cast<ChatEntry>(),
      uniqueIdentificationNumber: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserViceData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.messages)
      ..writeByte(1)
      ..write(obj.uniqueIdentificationNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserViceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
