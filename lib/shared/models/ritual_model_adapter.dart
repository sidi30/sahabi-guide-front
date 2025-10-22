import 'package:hive/hive.dart';
import 'ritual_model.dart';

part 'ritual_model_adapter.g.dart';

// TypeAdapter pour RitualType
class RitualTypeAdapter extends TypeAdapter<RitualType> {
  @override
  final int typeId = 0;

  @override
  RitualType read(BinaryReader reader) {
    final index = reader.readByte();
    return RitualType.values[index];
  }

  @override
  void write(BinaryWriter writer, RitualType obj) {
    writer.writeByte(obj.index);
  }
}

// TypeAdapter pour RitualStatus
class RitualStatusAdapter extends TypeAdapter<RitualStatus> {
  @override
  final int typeId = 1;

  @override
  RitualStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return RitualStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, RitualStatus obj) {
    writer.writeByte(obj.index);
  }
}

// TypeAdapter pour RitualModel
class RitualModelAdapter extends TypeAdapter<RitualModel> {
  @override
  final int typeId = 2;

  @override
  RitualModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return RitualModel(
      id: fields[0] as String,
      name: fields[1] as String,
      order: fields[2] as int,
      description: fields[3] as String,
      type: fields[4] as RitualType,
      status: fields[5] as RitualStatus,
      scheduledTime: fields[6] as DateTime?,
      completedAt: fields[7] as DateTime?,
      estimatedDuration: fields[8] != null 
          ? Duration(microseconds: fields[8] as int) 
          : null,
      audioPaths: (fields[9] as List?)?.cast<String>() ?? [],
      videoPath: fields[10] as String?,
      steps: (fields[11] as List?)?.cast<String>() ?? [],
      practicalTips: fields[12] != null 
          ? Map<String, String>.from(fields[12] as Map)
          : {},
      contentVersion: fields[13] as int?,
      translations: fields[14] != null 
          ? Map<String, String>.from(fields[14] as Map)
          : {},
      tags: (fields[15] as List?)?.cast<String>() ?? [],
      isActive: fields[16] as bool? ?? false,
      nextRitualId: fields[17] as String?,
      previousRitualId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RitualModel obj) {
    writer
      ..writeByte(19) // nombre de champs
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.scheduledTime)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.estimatedDuration?.inMicroseconds)
      ..writeByte(9)
      ..write(obj.audioPaths)
      ..writeByte(10)
      ..write(obj.videoPath)
      ..writeByte(11)
      ..write(obj.steps)
      ..writeByte(12)
      ..write(obj.practicalTips)
      ..writeByte(13)
      ..write(obj.contentVersion)
      ..writeByte(14)
      ..write(obj.translations)
      ..writeByte(15)
      ..write(obj.tags)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.nextRitualId)
      ..writeByte(18)
      ..write(obj.previousRitualId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RitualModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

