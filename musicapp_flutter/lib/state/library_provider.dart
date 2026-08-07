import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/purchase_entry.dart';
import '../models/recent_entry.dart';
import '../models/track.dart';
import '../services/favorites_repository.dart';
import '../services/playlists_repository.dart';
import '../services/purchases_repository.dart';
import '../services/recent_repository.dart';

/// Central state for everything persisted on-device: favorites, playlists,
/// recently-played history and self-reported purchases. All screens read
/// from this single provider so counts/badges stay in sync everywhere.
class LibraryProvider extends ChangeNotifier {
  final FavoritesRepository _favoritesRepo;
  final PlaylistsRepository _playlistsRepo;
  final RecentRepository _recentRepo;
  final PurchasesRepository _purchasesRepo;

  List<Track> _favorites = [];
  List<Playlist> _playlists = [];
  List<RecentEntry> _recent = [];
  Set<int> _purchasedTrackIds = {};

  LibraryProvider({
    FavoritesRepository? favoritesRepo,
    PlaylistsRepository? playlistsRepo,
    RecentRepository? recentRepo,
    PurchasesRepository? purchasesRepo,
  })  : _favoritesRepo = favoritesRepo ?? FavoritesRepository(),
        _playlistsRepo = playlistsRepo ?? PlaylistsRepository(),
        _recentRepo = recentRepo ?? RecentRepository(),
        _purchasesRepo = purchasesRepo ?? PurchasesRepository() {
    _loadAll();
  }

  List<Track> get favorites => _favorites;
  List<Playlist> get playlists => _playlists;
  List<RecentEntry> get recent => _recent;
  Set<int> get purchasedTrackIds => _purchasedTrackIds;

  int get favoritesCount => _favorites.length;
  int get playlistsCount => _playlists.length;
  int get recentCount => _recent.length;
  List<PurchaseEntry> get purchaseHistory => _purchasesRepo.getAll();

  void _loadAll() {
    _favorites = _favoritesRepo.getAll();
    _playlists = _playlistsRepo.getAll();
    _recent = _recentRepo.getAll();
    _purchasedTrackIds = _purchasesRepo.getPurchasedTrackIds();
  }

  bool isFavorite(int trackId) => _favoritesRepo.isFavorite(trackId);
  bool isPurchased(int trackId) => _purchasedTrackIds.contains(trackId);

  Future<void> toggleFavorite(Track track) async {
    await _favoritesRepo.toggle(track);
    _favorites = _favoritesRepo.getAll();
    notifyListeners();
  }

  Future<void> recordPlay(Track track) async {
    await _recentRepo.recordPlay(track);
    _recent = _recentRepo.getAll();
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await _recentRepo.clear();
    _recent = [];
    notifyListeners();
  }

  Future<void> confirmPurchase(Track track) async {
    await _purchasesRepo.confirm(track);
    _purchasedTrackIds = _purchasesRepo.getPurchasedTrackIds();
    notifyListeners();
  }

  bool playlistNameTaken(String name) => _playlistsRepo.nameTaken(name);

  Future<Playlist?> createPlaylist(String name) async {
    if (playlistNameTaken(name)) return null;
    final playlist = await _playlistsRepo.create(name);
    _playlists = _playlistsRepo.getAll();
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String id, String name) async {
    await _playlistsRepo.rename(id, name);
    _playlists = _playlistsRepo.getAll();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistsRepo.delete(id);
    _playlists = _playlistsRepo.getAll();
    notifyListeners();
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    await _playlistsRepo.addTrack(playlistId, track);
    _playlists = _playlistsRepo.getAll();
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(String playlistId, int trackId) async {
    await _playlistsRepo.removeTrack(playlistId, trackId);
    _playlists = _playlistsRepo.getAll();
    notifyListeners();
  }

  Playlist? getPlaylist(String id) => _playlistsRepo.getById(id);

  /// Full on-device export, matching the shape of the web app's
  /// `/api/account/export` JSON download.
  Map<String, dynamic> exportData() {
    return {
      'favorites': _favorites.map((t) => t.toJson()).toList(),
      'playlists': _playlists
          .map((p) => {
                'name': p.name,
                'createdAt': p.createdAt.toIso8601String(),
                'tracks': p.tracks.map((t) => t.toJson()).toList(),
              })
          .toList(),
      'recentlyPlayed': _recent
          .map((r) => {
                'playedAt': r.playedAt.toIso8601String(),
                'track': r.track.toJson(),
              })
          .toList(),
      'purchases': purchaseHistory
          .map((p) => {
                'trackId': p.trackId,
                'trackName': p.trackName,
                'artistName': p.artistName,
                'confirmedAt': p.confirmedAt.toIso8601String(),
              })
          .toList(),
    };
  }

  Future<void> clearAllData() async {
    for (final playlist in List.of(_playlists)) {
      await _playlistsRepo.delete(playlist.id);
    }
    await _recentRepo.clear();
    for (final track in List.of(_favorites)) {
      await _favoritesRepo.remove(track.trackId);
    }
    _loadAll();
    notifyListeners();
  }
}
