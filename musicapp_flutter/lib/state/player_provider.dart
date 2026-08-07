import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';

/// Drives the mini-player: plays a track's 30-second iTunes preview,
/// exposes playback position/duration for the synced-lyrics view, and
/// keeps only one preview playing at a time.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Track? _currentTrack;
  bool _visible = false;

  /// Called whenever a *new* track starts playing (not on pause/resume of
  /// the same track), so the app can record it under "Recent" without this
  /// provider needing to know about LibraryProvider directly.
  void Function(Track track)? onTrackStarted;

  PlayerProvider() {
    _player.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        _visible = false;
        notifyListeners();
      }
    });
    _player.positionStream.listen((_) => notifyListeners());
  }

  Track? get currentTrack => _currentTrack;
  bool get visible => _visible;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  Stream<Duration> get positionStream => _player.positionStream;

  Future<void> playTrack(Track track) async {
    if (track.previewUrl == null || track.previewUrl!.isEmpty) return;

    if (_currentTrack?.trackId == track.trackId) {
      // Same track: toggle play/pause instead of restarting.
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
        _visible = true;
      }
      notifyListeners();
      return;
    }

    _currentTrack = track;
    _visible = true;
    notifyListeners();

    try {
      await _player.setUrl(track.previewUrl!);
      await _player.play();
      onTrackStarted?.call(track);
    } catch (_) {
      // Preview URL failed to load (expired/unavailable) — quietly hide the player.
      _visible = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> close() async {
    await _player.stop();
    _visible = false;
    _currentTrack = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
