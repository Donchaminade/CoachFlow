// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoachAdapter extends TypeAdapter<Coach> {
  @override
  final int typeId = 0;

  @override
  Coach read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Coach(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      systemPrompt: fields[3] as String,
      avatarIcon: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Coach obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.systemPrompt)
      ..writeByte(4)
      ..write(obj.avatarIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
