import '../models/purchase_entry.dart';
import '../models/track.dart';
import 'storage_service.dart';

/// Local persistence for self-reported purchase confirmations. The app
/// never processes real payments — this only remembers that the person
/// said "yes, I bought this on iTunes" so a badge can be shown later.
class PurchasesRepository {
  Set<int> getPurchasedTrackIds() {
    return StorageService.purchases.values.map((p) => p.trackId).toSet();
  }

  List<PurchaseEntry> getAll() {
    final list = StorageService.purchases.values.toList();
    list.sort((a, b) => b.confirmedAt.compareTo(a.confirmedAt));
    return list;
  }

  bool isPurchased(int trackId) => getPurchasedTrackIds().contains(trackId);

  Future<void> confirm(Track track) async {
    final entry = PurchaseEntry(
      trackId: track.trackId,
      trackName: track.trackName,
      artistName: track.artistName,
      trackViewUrl: track.trackViewUrl,
      confirmedAt: DateTime.now(),
    );
    await StorageService.purchases.put(track.trackId, entry);
  }

  int get count => StorageService.purchases.length;
}
