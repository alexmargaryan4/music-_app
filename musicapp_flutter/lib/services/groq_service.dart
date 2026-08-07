import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import 'itunes_service.dart';

/// What GroqService hands back to the UI: the assistant's text plus any
/// tracks it recommended (already resolved against iTunes for artwork,
/// price and previews).
class ChatReply {
  final String message;
  final List<Track> tracks;

  const ChatReply({required this.message, required this.tracks});
}

class ChatTurn {
  final String role; // "user" | "assistant"
  final String content;

  const ChatTurn({required this.role, required this.content});
}

/// Talks directly to the Groq chat-completions API from the phone.
///
/// NOTE: in the original web app this call was proxied through a Java
/// backend so the API key never left the server. Here, per the chosen
/// no-backend architecture, the key ships inside the app binary — anyone
/// determined enough could extract it from the APK/IPA. Swap
/// [GroqConfig.apiKey] for your own key, and consider rotating it if you
/// ever suspect abuse.
class GroqConfig {
  /// TODO: put your own Groq API key here before building the app.
  /// Get one for free at https://console.groq.com/keys
  static const String apiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: 'REPLACE_WITH_YOUR_GROQ_API_KEY',
  );

  static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String model = 'llama-3.3-70b-versatile';
}

class GroqService {
  static const int _maxRecommendations = 6;

  final http.Client _client;
  final ITunesService _iTunesService;

  GroqService({http.Client? client, ITunesService? iTunesService})
      : _client = client ?? http.Client(),
        _iTunesService = iTunesService ?? ITunesService();

  /// Sends the user's message (plus short history and last search context)
  /// to Groq, asking for a strict JSON reply so recommended songs can be
  /// rendered as real track cards instead of plain text.
  Future<ChatReply> getRecommendation({
    required String message,
    List<ChatTurn> history = const [],
    String? lastSearchTerm,
    String language = 'en',
  }) async {
    final lang = _normalizeLanguage(language);
    final systemPrompt = _buildSystemPrompt(lang);

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // keep only the last 10 turns to control token usage
    final start = history.length > 10 ? history.length - 10 : 0;
    for (var i = start; i < history.length; i++) {
      final turn = history[i];
      final role = turn.role.toLowerCase() == 'assistant' ? 'assistant' : 'user';
      messages.add({'role': role, 'content': turn.content});
    }

    var userContent = message;
    if (lastSearchTerm != null && lastSearchTerm.trim().isNotEmpty) {
      userContent = '$userContent\n\n[Context: the user\'s last search on the app was for "$lastSearchTerm"]';
    }
    messages.add({'role': 'user', 'content': userContent});

    final body = jsonEncode({
      'model': GroqConfig.model,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 500,
      'response_format': {'type': 'json_object'},
    });

    try {
      final response = await _client
          .post(
            Uri.parse(GroqConfig.apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${GroqConfig.apiKey}',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return ChatReply(message: _fallbackMessage(lang), tracks: const []);
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return ChatReply(message: _fallbackMessage(lang), tracks: const []);
      }

      final rawReply = (choices.first['message']?['content'] as String?)?.trim();
      if (rawReply == null || rawReply.isEmpty) {
        return ChatReply(message: _fallbackMessage(lang), tracks: const []);
      }

      return await _parseStructuredReply(rawReply, lang);
    } catch (_) {
      return ChatReply(message: _fallbackMessage(lang), tracks: const []);
    }
  }

  Future<ChatReply> _parseStructuredReply(String rawReply, String language) async {
    try {
      final structured = jsonDecode(rawReply) as Map<String, dynamic>;
      var message = (structured['message'] as String?)?.trim() ?? '';
      if (message.isEmpty) {
        message = _fallbackMessage(language);
      }
      final recommendations = (structured['recommendations'] as List<dynamic>?) ?? [];
      final tracks = await _resolveTracks(recommendations);
      return ChatReply(message: message, tracks: tracks);
    } catch (_) {
      // Model didn't return valid JSON — fall back to showing its raw text with no cards.
      return ChatReply(message: rawReply, tracks: const []);
    }
  }

  Future<List<Track>> _resolveTracks(List<dynamic> recommendations) async {
    if (recommendations.isEmpty) return [];

    final tracks = <Track>[];
    final limit = recommendations.length < _maxRecommendations
        ? recommendations.length
        : _maxRecommendations;

    for (var i = 0; i < limit; i++) {
      final rec = recommendations[i] as Map<String, dynamic>?;
      if (rec == null) continue;
      final title = (rec['title'] as String?)?.trim();
      if (title == null || title.isEmpty) continue;
      final artist = (rec['artist'] as String?)?.trim();
      final term = (artist != null && artist.isNotEmpty) ? '$title $artist' : title;

      final found = await _iTunesService.searchSongs(term, limit: 1);
      if (found.isNotEmpty) {
        tracks.add(found.first);
      }
    }
    return tracks;
  }

  String _normalizeLanguage(String? lang) {
    if (lang == null) return 'en';
    final lower = lang.toLowerCase();
    if (lower == 'ru' || lower == 'hy') return lower;
    return 'en';
  }

  String _buildSystemPrompt(String language) {
    final languageInstruction = switch (language) {
      'ru' => 'Отвечай ТОЛЬКО на русском языке.',
      'hy' => 'Պատասխանիր ՄԻԱՅՆ հայերենով։',
      _ => 'Respond ONLY in English.',
    };

    return 'You are a friendly, knowledgeable music recommendation assistant inside a music '
        'discovery mobile app called MusicApp. The app lets users search songs via the '
        'iTunes API and save favorites. When the user tells you what they searched for, or '
        'describes a mood/genre/artist they like, recommend specific real songs and artists '
        'that fit, briefly explain why, and keep your answer concise (max ~120 words), '
        'friendly and conversational. Do not invent fake songs; recommend real, well-known '
        'tracks/artists. $languageInstruction '
        'You must reply with ONLY a single valid JSON object, no markdown fences and no text '
        'outside the JSON, in exactly this shape: '
        '{"message": string, "recommendations": [{"title": string, "artist": string}]}. '
        'Put your conversational reply in "message". Whenever you recommend specific songs, '
        'list each one as a {title, artist} object in "recommendations" (max 6 items) instead '
        'of writing the song titles inside "message" — the app renders those as visual song '
        'cards with artwork automatically, so just refer to them naturally in the text (e.g. '
        '"Here are a few picks for you:"). If you are not recommending any specific songs '
        '(e.g. just chatting or asking a clarifying question), set "recommendations" to an '
        'empty array.';
  }

  String _fallbackMessage(String language) {
    return switch (language) {
      'ru' => 'Извините, сейчас я не могу связаться с сервисом рекомендаций. Попробуйте ещё раз чуть позже.',
      'hy' => 'Ներողություն, այս պահին առաջարկությունների ծառայությանը հասանելի չեմ։ Փորձեք մի փոքր ուշ։',
      _ => "Sorry, I can't reach the recommendation service right now. Please try again shortly.",
    };
  }
}
