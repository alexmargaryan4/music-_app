// GENERATED CODE - DO NOT MODIFY BY HAND
// (Hand-written to match what build_runner would produce for the
// @HiveType(typeId: 3) PurchaseEntry class — see the note in track.g.dart.)

part of 'purchase_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseEntryAdapter extends TypeAdapter<PurchaseEntry> {
  @override
  final int typeId = 3;

  @override
  PurchaseEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseEntry(
      trackId: (fields[0] as num).toInt(),
      trackName: fields[1] as String?,
      artistName: fields[2] as String?,
      trackViewUrl: fields[3] as String?,
      confirmedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.trackName)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.trackViewUrl)
      ..writeByte(4)
      ..write(obj.confirmedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
