import '../models/track.dart';
import 'storage_service.dart';

/// Local persistence for favorited tracks, keyed by trackId.
class FavoritesRepository {
  List<Track> getAll() {
    final box = StorageService.favorites;
    final list = box.values.toList();
    list.sort((a, b) => b.key.compareTo(a.key)); // newest-added first
    return list;
  }

  bool isFavorite(int trackId) => StorageService.favorites.containsKey(trackId);

  Future<void> add(Track track) async {
    await StorageService.favorites.put(track.trackId, track);
  }

  Future<void> remove(int trackId) async {
    await StorageService.favorites.delete(trackId);
  }

  Future<void> toggle(Track track) async {
    if (isFavorite(track.trackId)) {
      await remove(track.trackId);
    } else {
      await add(track);
    }
  }

  int get count => StorageService.favorites.length;
}
