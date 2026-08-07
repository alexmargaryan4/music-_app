// GENERATED CODE - DO NOT MODIFY BY HAND
// (Hand-written to match what build_runner would produce for the
// @HiveType(typeId: 2) RecentEntry class — see the note in track.g.dart.)

part of 'recent_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentEntryAdapter extends TypeAdapter<RecentEntry> {
  @override
  final int typeId = 2;

  @override
  RecentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentEntry(
      track: fields[0] as Track,
      playedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.track)
      ..writeByte(1)
      ..write(obj.playedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
