import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lyrics.dart';
import '../models/track.dart';
import '../services/lyrics_service.dart';
import '../state/player_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';

/// Full-screen synced-lyrics view — Spotify-style real-time line
/// highlighting, mirroring the web app's `#lyrics-backdrop` panel.
///
/// Because iTunes previews are only ~30s clips, most songs will only light
/// up their first few lines during playback — that's expected, not a bug.
class LyricsScreen extends StatefulWidget {
  final Track track;
  const LyricsScreen({super.key, required this.track});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final _lyricsService = LyricsService();
  final _scrollController = ScrollController();
  LyricsResult? _result;
  bool _loading = true;
  bool _error = false;
  int _activeIndex = -1;
  StreamSubscription<Duration>? _positionSub;

  @override
  void initState() {
    super.initState();
    _load();
    _listenToPlayback();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final durationSeconds = widget.track.trackTimeMillis != null
          ? (widget.track.trackTimeMillis! / 1000).round()
          : null;
      final result = await _lyricsService.getLyrics(
        trackName: widget.track.trackName ?? '',
        artistName: widget.track.artistName ?? '',
        albumName: widget.track.collectionName,
        durationSeconds: durationSeconds,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _listenToPlayback() {
    final player = context.read<PlayerProvider>();
    _positionSub = player.positionStream.listen((position) {
      if (player.currentTrack?.trackId != widget.track.trackId) return;
      final result = _result;
      if (result == null || !result.synced) return;

      final seconds = position.inMilliseconds / 1000.0;
      var newIndex = -1;
      for (var i = 0; i < result.lines.length; i++) {
        final lineTime = result.lines[i].time;
        if (lineTime != null && lineTime <= seconds) {
          newIndex = i;
        } else {
          break;
        }
      }
      if (newIndex != _activeIndex) {
        setState(() => _activeIndex = newIndex);
        _scrollToActiveLine();
      }
    });
  }

  void _scrollToActiveLine() {
    if (_activeIndex < 0 || !_scrollController.hasClients) return;
    final targetOffset = (_activeIndex * 52.0) - 120;
    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;
    final player = context.watch<PlayerProvider>();
    final isThisTrackPlaying = player.currentTrack?.trackId == widget.track.trackId;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.track.artworkUrlHigh != null
                        ? CachedNetworkImage(
                            imageUrl: widget.track.artworkUrlHigh!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 44, height: 44, color: colors.text0.withValues(alpha: 0.08)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.track.trackName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          widget.track.artistName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_result?.synced == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        strings.t('lyrics.synced'),
                        style: TextStyle(color: colors.accent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody(context, strings)),
            if (widget.track.previewUrl != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    IconButton.filled(
                      icon: Icon(isThisTrackPlaying && player.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      onPressed: () => context.read<PlayerProvider>().playTrack(widget.track),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: isThisTrackPlaying && player.duration != null && player.duration!.inMilliseconds > 0
                            ? player.position.inMilliseconds / player.duration!.inMilliseconds
                            : 0,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: colors.text0.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic strings) {
    final colors = context.colors;

    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(strings.t('lyrics.loading'), style: TextStyle(color: colors.text2)),
          ],
        ),
      );
    }

    if (_error) {
      return Center(
        child: Text(strings.t('lyrics.error'), style: TextStyle(color: colors.text2)),
      );
    }

    final result = _result;
    if (result == null || !result.found) {
      return Center(
        child: Text(strings.t('lyrics.notfound'), style: TextStyle(color: colors.text2)),
      );
    }

    if (result.instrumental) {
      return Center(
        child: Text(strings.t('lyrics.instrumental'), style: TextStyle(color: colors.text2)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      itemCount: result.lines.length,
      itemBuilder: (context, index) {
        final line = result.lines[index];
        final isActive = result.synced && index == _activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isActive ? 20 : 17,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? colors.text0 : colors.text2,
              height: 1.4,
            ),
            child: Text(line.text.isEmpty ? '♪' : line.text),
          ),
        );
      },
    );
  }
}
