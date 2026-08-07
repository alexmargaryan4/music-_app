import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyrics.dart';

/// Fetches time-synced lyrics (LRC format) from the free, keyless LRCLIB
/// API (https://lrclib.net) so the player can highlight the
/// currently-sung line in real time, Spotify-style.
///
/// iTunes (our music source) does not provide lyrics at all, so this hits
/// a separate, dedicated lyrics provider matched by track/artist/album name.
class LyricsService {
  static const String _getUrl = 'https://lrclib.net/api/get';
  static const String _searchUrl = 'https://lrclib.net/api/search';

  // [mm:ss.xx] or [mm:ss.xxx] or [hh:mm:ss.xx] line-timestamp prefix
  static final RegExp _lrcTimestamp = RegExp(r'^\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?]');

  final http.Client _client;
  final Map<String, LyricsResult> _cache = {};

  LyricsService({http.Client? client}) : _client = client ?? http.Client();

  Future<LyricsResult> getLyrics({
    required String trackName,
    required String artistName,
    String? albumName,
    int? durationSeconds,
  }) async {
    if (trackName.trim().isEmpty || artistName.trim().isEmpty) {
      return LyricsResult.notFound();
    }

    final cacheKey = '${artistName.toLowerCase()}|${trackName.toLowerCase()}';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    var result = await _fetchExact(trackName, artistName, albumName, durationSeconds);
    if (!result.found) {
      result = await _fetchViaSearch(trackName, artistName);
    }

    _cache[cacheKey] = result;
    return result;
  }

  /// Tries LRCLIB's exact "/get" endpoint first (best match quality).
  Future<LyricsResult> _fetchExact(
    String trackName,
    String artistName,
    String? albumName,
    int? durationSeconds,
  ) async {
    final params = <String, String>{
      'track_name': trackName,
      'artist_name': artistName,
    };
    if (albumName != null && albumName.trim().isNotEmpty) {
      params['album_name'] = albumName;
    }
    if (durationSeconds != null && durationSeconds > 0) {
      params['duration'] = '$durationSeconds';
    }

    try {
      final uri = Uri.parse(_getUrl).replace(queryParameters: params);
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return LyricsResult.notFound();

      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return _toResult(json);
    } catch (_) {
      return LyricsResult.notFound();
    }
  }

  /// Falls back to LRCLIB's fuzzy "/search" endpoint and takes the best candidate.
  Future<LyricsResult> _fetchViaSearch(String trackName, String artistName) async {
    try {
      final uri = Uri.parse(_searchUrl).replace(queryParameters: {
        'track_name': trackName,
        'artist_name': artistName,
      });
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return LyricsResult.notFound();

      final results = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      if (results.isEmpty) return LyricsResult.notFound();

      Map<String, dynamic>? best;
      for (final r in results) {
        final map = r as Map<String, dynamic>;
        final synced = map['syncedLyrics'] as String?;
        if (synced != null && synced.trim().isNotEmpty) {
          best = map;
          break;
        }
        final plain = map['plainLyrics'] as String?;
        if (best == null && plain != null && plain.trim().isNotEmpty) {
          best = map;
        }
      }
      best ??= results.first as Map<String, dynamic>;

      return _toResult(best);
    } catch (_) {
      return LyricsResult.notFound();
    }
  }

  LyricsResult _toResult(Map<String, dynamic> json) {
    final instrumental = json['instrumental'] as bool? ?? false;
    if (instrumental) {
      return const LyricsResult(found: true, synced: false, instrumental: true, lines: []);
    }

    final syncedLyrics = json['syncedLyrics'] as String?;
    if (syncedLyrics != null && syncedLyrics.trim().isNotEmpty) {
      final lines = _parseLrc(syncedLyrics);
      if (lines.isNotEmpty) {
        return LyricsResult(found: true, synced: true, instrumental: false, lines: lines);
      }
    }

    final plainLyrics = json['plainLyrics'] as String?;
    if (plainLyrics != null && plainLyrics.trim().isNotEmpty) {
      final lines = plainLyrics
          .split(RegExp(r'\r?\n'))
          .map((line) => LyricLine(time: null, text: line))
          .toList();
      return LyricsResult(found: true, synced: false, instrumental: false, lines: lines);
    }

    return LyricsResult.notFound();
  }

  /// Parses standard LRC syntax ("[01:23.45]Some lyric line") into timed lines.
  List<LyricLine> _parseLrc(String lrc) {
    final lines = <LyricLine>[];
    for (final rawLine in lrc.split(RegExp(r'\r?\n'))) {
      if (rawLine.trim().isEmpty) continue;

      final match = _lrcTimestamp.firstMatch(rawLine);
      if (match == null) continue; // skip metadata tags like [ar:], [ti:], [by:] etc.

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final fraction = match.group(3);
      var frac = 0.0;
      if (fraction != null) {
        // normalize 1-3 digit fraction to a decimal value (e.g. "5" -> 0.5, "45" -> 0.45)
        frac = double.parse('0.$fraction');
      }
      final timeSeconds = minutes * 60 + seconds + frac;
      final text = rawLine.substring(match.end).trim();
      lines.add(LyricLine(time: timeSeconds, text: text));
    }
    lines.sort((a, b) => (a.time ?? 0).compareTo(b.time ?? 0));
    return lines;
  }
}
