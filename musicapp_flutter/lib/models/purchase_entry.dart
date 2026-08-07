import 'package:hive/hive.dart';

part 'purchase_entry.g.dart';

/// Records that the user *self-reported* buying a track on the official
/// Apple iTunes Store. The app never processes real payments or verifies
/// anything with Apple — it just remembers the user's own confirmation so
/// a "Purchased" badge can be shown next to that track later.
@HiveType(typeId: 3)
class PurchaseEntry extends HiveObject {
  @HiveField(0)
  final int trackId;

  @HiveField(1)
  final String? trackName;

  @HiveField(2)
  final String? artistName;

  @HiveField(3)
  final String? trackViewUrl;

  @HiveField(4)
  final DateTime confirmedAt;

  PurchaseEntry({
    required this.trackId,
    this.trackName,
    this.artistName,
    this.trackViewUrl,
    required this.confirmedAt,
  });
}
