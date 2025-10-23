// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_step_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationStepModelAdapter extends TypeAdapter<ConversationStepModel> {
  @override
  final int typeId = 10;

  @override
  ConversationStepModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationStepModel(
      id: fields[0] as String,
      stepCode: fields[1] as String,
      stepOrder: fields[2] as int,
      question: fields[3] as String,
      questionAr: fields[4] as String?,
      questionEn: fields[5] as String?,
      answerType: fields[6] as String,
      answerOptions: (fields[7] as List?)?.cast<String>(),
      helpText: fields[8] as String?,
      relatedRitualId: fields[9] as String?,
      isCritical: fields[10] as bool?,
      reminderAfterHours: fields[11] as int?,
      nextStepCode: fields[12] as String?,
      navigationRules: (fields[13] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversationStepModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stepCode)
      ..writeByte(2)
      ..write(obj.stepOrder)
      ..writeByte(3)
      ..write(obj.question)
      ..writeByte(4)
      ..write(obj.questionAr)
      ..writeByte(5)
      ..write(obj.questionEn)
      ..writeByte(6)
      ..write(obj.answerType)
      ..writeByte(7)
      ..write(obj.answerOptions)
      ..writeByte(8)
      ..write(obj.helpText)
      ..writeByte(9)
      ..write(obj.relatedRitualId)
      ..writeByte(10)
      ..write(obj.isCritical)
      ..writeByte(11)
      ..write(obj.reminderAfterHours)
      ..writeByte(12)
      ..write(obj.nextStepCode)
      ..writeByte(13)
      ..write(obj.navigationRules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationStepModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
