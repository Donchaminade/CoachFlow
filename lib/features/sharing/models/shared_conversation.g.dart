// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedConversationAdapter extends TypeAdapter<SharedConversation> {
  @override
  final int typeId = 4;

  @override
  SharedConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedConversation(
      id: fields[0] as String,
      sharedBy: fields[1] as String,
      coach: fields[2] as Coach,
      messages: (fields[3] as List).cast<Message>(),
      sharedAt: fields[4] as DateTime,
      title: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SharedConversation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sharedBy)
      ..writeByte(2)
      ..write(obj.coach)
      ..writeByte(3)
      ..write(obj.messages)
      ..writeByte(4)
      ..write(obj.sharedAt)
      ..writeByte(5)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
