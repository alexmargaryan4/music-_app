import 'package:hive/hive.dart';
import 'track.dart';

part 'recent_entry.g.dart';

/// Wraps a [Track] with the timestamp it was last played at, so the
/// "Recent" tab can be sorted newest-first without mutating Track itself.
@HiveType(typeId: 2)
class RecentEntry extends HiveObject {
  @HiveField(0)
  final Track track;

  @HiveField(1)
  final DateTime playedAt;

  RecentEntry({required this.track, required this.playedAt});
}
