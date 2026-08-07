import 'package:uuid/uuid.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import 'storage_service.dart';

/// Local persistence for user-created playlists.
class PlaylistsRepository {
  static const _uuid = Uuid();

  List<Playlist> getAll() {
    final list = StorageService.playlists.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Playlist? getById(String id) {
    try {
      return StorageService.playlists.values.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  bool nameTaken(String name) {
    final normalized = name.trim().toLowerCase();
    return StorageService.playlists.values.any((p) => p.name.trim().toLowerCase() == normalized);
  }

  Future<Playlist> create(String name) async {
    final playlist = Playlist(id: _uuid.v4(), name: name.trim(), createdAt: DateTime.now());
    await StorageService.playlists.put(playlist.id, playlist);
    return playlist;
  }

  Future<Playlist?> rename(String id, String newName) async {
    final playlist = getById(id);
    if (playlist == null) return null;
    playlist.name = newName.trim();
    await playlist.save();
    return playlist;
  }

  Future<void> delete(String id) async {
    await StorageService.playlists.delete(id);
  }

  Future<Playlist?> addTrack(String playlistId, Track track) async {
    final playlist = getById(playlistId);
    if (playlist == null) return null;
    final alreadyIn = playlist.tracks.any((t) => t.trackId == track.trackId);
    if (!alreadyIn) {
      playlist.tracks.add(track);
      await playlist.save();
    }
    return playlist;
  }

  Future<Playlist?> removeTrack(String playlistId, int trackId) async {
    final playlist = getById(playlistId);
    if (playlist == null) return null;
    playlist.tracks.removeWhere((t) => t.trackId == trackId);
    await playlist.save();
    return playlist;
  }

  int get count => StorageService.playlists.length;
}
