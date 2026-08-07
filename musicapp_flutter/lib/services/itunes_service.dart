import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

/// Talks directly to Apple's public iTunes Search API. No API key is
/// required — this mirrors the Java backend's ITunesService, just called
/// straight from the phone instead of proxied through a server.
class ITunesService {
  static const String _searchUrl = 'https://itunes.apple.com/search';
  static const String _lookupUrl = 'https://itunes.apple.com/lookup';
  static const String _defaultCountry = 'US';

  final http.Client _client;

  ITunesService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Track>> searchSongs(String term, {int limit = 24}) async {
    final query = term.trim();
    if (query.isEmpty) return [];

    final clampedLimit = limit.clamp(1, 50);
    final uri = Uri.parse(_searchUrl).replace(queryParameters: {
      'term': query,
      'entity': 'song',
      'media': 'music',
      'limit': '$clampedLimit',
      'country': _defaultCountry,
    });

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final results = (body['results'] as List<dynamic>?) ?? [];

      return results
          .whereType<Map<String, dynamic>>()
          .where((json) => json['trackId'] != null)
          .map(Track.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Looks up a single track by its iTunes trackId (used to refresh a
  /// stale preview URL, which iTunes rotates periodically).
  Future<Track?> lookupTrack(int trackId) async {
    final uri = Uri.parse(_lookupUrl).replace(queryParameters: {'id': '$trackId'});
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final results = (body['results'] as List<dynamic>?) ?? [];
      if (results.isEmpty) return null;

      return Track.fromJson(results.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
