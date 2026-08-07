import '../models/recent_entry.dart';
import '../models/track.dart';
import 'storage_service.dart';

/// Local persistence for recently-played tracks. Keeps at most one entry
/// per track (re-playing bumps it to the top with a fresh timestamp).
class RecentRepository {
  static const int _maxEntries = 100;

  List<RecentEntry> getAll() {
    final list = StorageService.recent.values.toList();
    list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return list;
  }

  Future<void> recordPlay(Track track) async {
    final box = StorageService.recent;

    // Remove any existing entry for this track so it doesn't appear twice.
    final keysToRemove = <dynamic>[];
    for (final key in box.keys) {
      final entry = box.get(key);
      if (entry != null && entry.track.trackId == track.trackId) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      await box.delete(key);
    }

    await box.add(RecentEntry(track: track, playedAt: DateTime.now()));

    // Trim oldest entries beyond the cap.
    if (box.length > _maxEntries) {
      final entries = box.toMap().entries.toList()
        ..sort((a, b) => a.value.playedAt.compareTo(b.value.playedAt));
      final overflow = box.length - _maxEntries;
      for (var i = 0; i < overflow; i++) {
        await box.delete(entries[i].key);
      }
    }
  }

  Future<void> clear() async {
    await StorageService.recent.clear();
  }

  int get count => StorageService.recent.length;
}
