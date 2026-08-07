import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_repository.dart';
import '../services/groq_service.dart';

/// Drives the AI recommendation chat screen: keeps message history (in
/// Hive, so it survives app restarts) and forwards new messages to Groq.
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;
  final GroqService _groqService;

  List<ChatMessageEntry> _messages = [];
  bool _thinking = false;
  String? _lastSearchTerm;

  ChatProvider({ChatRepository? repository, GroqService? groqService})
      : _repository = repository ?? ChatRepository(),
        _groqService = groqService ?? GroqService() {
    _messages = _repository.getHistory();
  }

  List<ChatMessageEntry> get messages => _messages;
  bool get thinking => _thinking;

  void setLastSearchTerm(String term) {
    _lastSearchTerm = term;
  }

  Future<void> sendMessage(String text, {required String language}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userEntry = ChatMessageEntry(role: 'user', content: trimmed);
    _messages = [..._messages, userEntry];
    await _repository.append(userEntry);
    _thinking = true;
    notifyListeners();

    final history = _messages
        .map((m) => ChatTurn(role: m.role, content: m.content))
        .toList();
    // Drop the message we just added — GroqService adds it separately with
    // the search-term context appended.
    if (history.isNotEmpty) history.removeLast();

    final reply = await _groqService.getRecommendation(
      message: trimmed,
      history: history,
      lastSearchTerm: _lastSearchTerm,
      language: language,
    );

    final assistantEntry = ChatMessageEntry(
      role: 'assistant',
      content: reply.message,
      tracks: reply.tracks.isEmpty ? null : reply.tracks,
    );
    _messages = [..._messages, assistantEntry];
    await _repository.append(assistantEntry);
    _thinking = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _repository.clear();
    _messages = [];
    notifyListeners();
  }
}
