/// A single line of (optionally time-synced) lyrics, parsed from raw LRC
/// syntax returned by the LRCLIB API.
class LyricLine {
  /// Line start time in seconds, relative to the start of the track.
  /// Null if the lyrics are unsynced (plain text only).
  final double? time;
  final String text;

  const LyricLine({this.time, required this.text});
}

/// Result of a lyrics lookup. `synced` tells the UI whether it can rely on
/// [LyricLine.time] for real-time karaoke-style highlighting, or should
/// just render plain text.
class LyricsResult {
  final bool found;
  final bool synced;
  final bool instrumental;
  final List<LyricLine> lines;

  const LyricsResult({
    required this.found,
    required this.synced,
    required this.instrumental,
    required this.lines,
  });

  factory LyricsResult.notFound() =>
      const LyricsResult(found: false, synced: false, instrumental: false, lines: []);
}
