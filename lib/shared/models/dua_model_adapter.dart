import 'package:hive/hive.dart';
import 'dua_model.dart';

part 'dua_model_adapter.g.dart';

// TypeAdapter pour DuaType
class DuaTypeAdapter extends TypeAdapter<DuaType> {
  @override
  final int typeId = 3;

  @override
  DuaType read(BinaryReader reader) {
    final index = reader.readByte();
    return DuaType.values[index];
  }

  @override
  void write(BinaryWriter writer, DuaType obj) {
    writer.writeByte(obj.index);
  }
}

// TypeAdapter pour DuaModel
class DuaModelAdapter extends TypeAdapter<DuaModel> {
  @override
  final int typeId = 4;

  @override
  DuaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return DuaModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      arabicText: fields[3] as String,
      transliteration: fields[4] as String,
      translation: fields[5] as String,
      type: fields[6] as DuaType,
      audioPath: fields[7] as String,
      duration: fields[8] != null 
          ? Duration(microseconds: fields[8] as int)
          : const Duration(minutes: 1),
      priority: fields[9] as int? ?? 1,
      tags: (fields[10] as List?)?.cast<String>() ?? [],
      isActive: fields[11] as bool? ?? true,
      isFavorite: fields[12] as bool? ?? false,
      translations: fields[13] != null 
          ? Map<String, String>.from(fields[13] as Map)
          : {},
      audioPaths: fields[14] != null 
          ? Map<String, String>.from(fields[14] as Map)
          : {},
      ritualId: fields[15] as String?,
      lastPlayedAt: fields[16] as DateTime?,
      playCount: fields[17] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, DuaModel obj) {
    writer
      ..writeByte(18) // nombre de champs
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.arabicText)
      ..writeByte(4)
      ..write(obj.transliteration)
      ..writeByte(5)
      ..write(obj.translation)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.audioPath)
      ..writeByte(8)
      ..write(obj.duration.inMicroseconds)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.isFavorite)
      ..writeByte(13)
      ..write(obj.translations)
      ..writeByte(14)
      ..write(obj.audioPaths)
      ..writeByte(15)
      ..write(obj.ritualId)
      ..writeByte(16)
      ..write(obj.lastPlayedAt)
      ..writeByte(17)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

