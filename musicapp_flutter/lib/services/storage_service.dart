import 'package:hive_flutter/hive_flutter.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/recent_entry.dart';
import '../models/purchase_entry.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';

/// Central place that opens every Hive box the app needs. Everything lives
/// only on-device — there is no server and no sync between devices.
class StorageService {
  static const String favoritesBox = 'favorites';
  static const String playlistsBox = 'playlists';
  static const String recentBox = 'recent';
  static const String purchasesBox = 'purchases';
  static const String profileBox = 'profile';
  static const String chatBox = 'chat';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    Hive.registerAdapter(TrackAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(RecentEntryAdapter());
    Hive.registerAdapter(PurchaseEntryAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(ChatMessageEntryAdapter());

    await Future.wait([
      Hive.openBox<Track>(favoritesBox),
      Hive.openBox<Playlist>(playlistsBox),
      Hive.openBox<RecentEntry>(recentBox),
      Hive.openBox<PurchaseEntry>(purchasesBox),
      Hive.openBox<UserProfile>(profileBox),
      Hive.openBox<ChatMessageEntry>(chatBox),
    ]);

    _initialized = true;
  }

  static Box<Track> get favorites => Hive.box<Track>(favoritesBox);
  static Box<Playlist> get playlists => Hive.box<Playlist>(playlistsBox);
  static Box<RecentEntry> get recent => Hive.box<RecentEntry>(recentBox);
  static Box<PurchaseEntry> get purchases => Hive.box<PurchaseEntry>(purchasesBox);
  static Box<UserProfile> get profile => Hive.box<UserProfile>(profileBox);
  static Box<ChatMessageEntry> get chat => Hive.box<ChatMessageEntry>(chatBox);
}
