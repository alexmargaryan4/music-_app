// GENERATED CODE - DO NOT MODIFY BY HAND
// (Hand-written to match what build_runner would produce for the
// @HiveType(typeId: 4) UserProfile class — see the note in track.g.dart.)

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 4;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      username: fields[0] as String,
      bio: fields[1] as String?,
      avatarPath: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      preferredLanguage: fields[4] as String,
      preferredTheme: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.bio)
      ..writeByte(2)
      ..write(obj.avatarPath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.preferredLanguage)
      ..writeByte(5)
      ..write(obj.preferredTheme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
