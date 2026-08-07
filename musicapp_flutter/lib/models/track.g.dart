// GENERATED CODE - DO NOT MODIFY BY HAND
// (Hand-written to match exactly what `flutter pub run build_runner build`
// would produce for the @HiveType(typeId: 0) Track class, since this
// environment cannot run build_runner. If you add/change @HiveField
// entries in track.dart, regenerate this file with build_runner instead
// of editing it by hand.)

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 0;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      trackId: (fields[0] as num).toInt(),
      trackName: fields[1] as String?,
      artistName: fields[2] as String?,
      collectionName: fields[3] as String?,
      artworkUrl100: fields[4] as String?,
      previewUrl: fields[5] as String?,
      trackPrice: fields[6] as double?,
      collectionPrice: fields[7] as double?,
      currency: fields[8] as String?,
      primaryGenreName: fields[9] as String?,
      releaseDate: fields[10] as String?,
      trackTimeMillis: fields[11] as int?,
      trackViewUrl: fields[12] as String?,
      country: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.trackName)
      ..writeByte(2)
      ..write(obj.artistName)
      ..writeByte(3)
      ..write(obj.collectionName)
      ..writeByte(4)
      ..write(obj.artworkUrl100)
      ..writeByte(5)
      ..write(obj.previewUrl)
      ..writeByte(6)
      ..write(obj.trackPrice)
      ..writeByte(7)
      ..write(obj.collectionPrice)
      ..writeByte(8)
      ..write(obj.currency)
      ..writeByte(9)
      ..write(obj.primaryGenreName)
      ..writeByte(10)
      ..write(obj.releaseDate)
      ..writeByte(11)
      ..write(obj.trackTimeMillis)
      ..writeByte(12)
      ..write(obj.trackViewUrl)
      ..writeByte(13)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
