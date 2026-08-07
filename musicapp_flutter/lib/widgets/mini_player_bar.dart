import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/player_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/glass_panel.dart';

/// Floating "now previewing" bar shown above the bottom nav bar while a
/// 30-second iTunes preview is playing — mirrors the web app's
/// `#mini-player`.
class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final colors = context.colors;
    final track = player.currentTrack;

    if (!player.visible || track == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GlassPanel(
        strong: true,
        borderRadius: 20,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: track.artworkUrlHigh != null
                  ? CachedNetworkImage(
                      imageUrl: track.artworkUrlHigh!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: colors.text0.withValues(alpha: 0.08),
                      child: Icon(Icons.music_note_rounded, color: colors.text2, size: 20),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.trackName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    track.artistName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
              color: colors.text0,
              onPressed: () => context.read<PlayerProvider>().togglePlayPause(),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: colors.text1,
              onPressed: () => context.read<PlayerProvider>().close(),
            ),
          ],
        ),
      ),
    );
  }
}
