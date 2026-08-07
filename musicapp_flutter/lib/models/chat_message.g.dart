// GENERATED CODE - DO NOT MODIFY BY HAND
// (Hand-written to match what build_runner would produce for the
// @HiveType(typeId: 5) ChatMessageEntry class — see the note in track.g.dart.)

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageEntryAdapter extends TypeAdapter<ChatMessageEntry> {
  @override
  final int typeId = 5;

  @override
  ChatMessageEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageEntry(
      role: fields[0] as String,
      content: fields[1] as String,
      tracks: (fields[2] as List?)?.cast<Track>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.tracks)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
