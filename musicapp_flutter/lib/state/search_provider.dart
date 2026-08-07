import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/itunes_service.dart';

enum SearchStatus { idle, loading, success, error }

/// Drives the search tab: talks to the iTunes API and tracks the last
/// search term so the AI chat can reference it for context.
class SearchProvider extends ChangeNotifier {
  final ITunesService _service;

  SearchProvider({ITunesService? service}) : _service = service ?? ITunesService();

  List<Track> _results = [];
  SearchStatus _status = SearchStatus.idle;
  String _lastQuery = '';

  List<Track> get results => _results;
  SearchStatus get status => _status;
  String get lastQuery => _lastQuery;
  bool get hasSearched => _lastQuery.isNotEmpty;

  Future<void> search(String term) async {
    final query = term.trim();
    if (query.isEmpty) return;

    _lastQuery = query;
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      final results = await _service.searchSongs(query, limit: 30);
      _results = results;
      _status = SearchStatus.success;
    } catch (_) {
      _results = [];
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  void clear() {
    _results = [];
    _lastQuery = '';
    _status = SearchStatus.idle;
    notifyListeners();
  }
}
