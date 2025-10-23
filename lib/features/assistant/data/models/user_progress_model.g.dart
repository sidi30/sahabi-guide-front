// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 11;

  @override
  UserProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgressModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      stepId: fields[2] as String,
      stepCode: fields[3] as String,
      answer: fields[4] as String,
      answeredAt: fields[5] as DateTime,
      syncedAt: fields[6] as DateTime?,
      isOffline: fields[7] as bool,
      deviceId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.stepId)
      ..writeByte(3)
      ..write(obj.stepCode)
      ..writeByte(4)
      ..write(obj.answer)
      ..writeByte(5)
      ..write(obj.answeredAt)
      ..writeByte(6)
      ..write(obj.syncedAt)
      ..writeByte(7)
      ..write(obj.isOffline)
      ..writeByte(8)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
