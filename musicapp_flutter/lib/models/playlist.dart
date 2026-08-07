import 'package:hive/hive.dart';
import 'track.dart';

part 'playlist.g.dart';

/// A user-created named collection of tracks, stored entirely on-device.
@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  List<Track> tracks;

  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    List<Track>? tracks,
  }) : tracks = tracks ?? [];

  int get trackCount => tracks.length;
}
