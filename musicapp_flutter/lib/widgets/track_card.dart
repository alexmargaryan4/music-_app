import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../state/library_provider.dart';
import '../state/player_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import 'price_tag.dart';

/// A single track tile used across Search / Favorites / Playlist / Recent
/// grids — mirrors the web app's `.track-card` component: square artwork
/// with a hover/tap overlay (play + heart + playlist-add), title, artist,
/// genre chip and price tag underneath.
class TrackCard extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onRemoveFromPlaylist;
  final bool removeMode;

  const TrackCard({
    super.key,
    required this.track,
    required this.onTap,
    this.onAddToPlaylist,
    this.onRemoveFromPlaylist,
    this.removeMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final strings = context.watch<SettingsProvider>().strings;

    final isFav = library.isFavorite(track.trackId);
    final isPurchased = library.isPurchased(track.trackId);
    final isCurrentlyPlaying = player.currentTrack?.trackId == track.trackId && player.isPlaying;
    final art = track.artworkUrlHigh;
    final price = formatPrice(track.effectivePrice, track.currency);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: art != null
                        ? CachedNetworkImage(
                            imageUrl: art,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: colors.text0.withValues(alpha: 0.06),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: colors.text0.withValues(alpha: 0.06),
                              child: Icon(Icons.music_note_rounded, color: colors.text2),
                            ),
                          )
                        : Container(
                            color: colors.text0.withValues(alpha: 0.06),
                            child: Icon(Icons.music_note_rounded, color: colors.text2),
                          ),
                  ),
                  if (isPurchased)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _PurchasedBadge(strings: strings),
                    ),
                  // Bottom gradient + action buttons (always visible on mobile,
                  // unlike the web app's hover-only overlay — touch has no hover).
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleIconButton(
                            icon: isCurrentlyPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            filled: true,
                            enabled: track.previewUrl != null && track.previewUrl!.isNotEmpty,
                            onTap: () => context.read<PlayerProvider>().playTrack(track),
                          ),
                          Row(
                            children: [
                              _CircleIconButton(
                                icon: removeMode ? Icons.close_rounded : Icons.playlist_add_rounded,
                                onTap: removeMode ? onRemoveFromPlaylist : onAddToPlaylist,
                                dark: true,
                              ),
                              const SizedBox(width: 6),
                              _CircleIconButton(
                                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                onTap: () => context.read<LibraryProvider>().toggleFavorite(track),
                                dark: true,
                                active: isFav,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              track.trackName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              track.artistName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if ((track.primaryGenreName ?? '').isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.text0.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.text0.withValues(alpha: 0.08)),
                      ),
                      child: Text(
                        track.primaryGenreName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                const Spacer(),
                if (price != null)
                  PriceTag(text: price)
                else
                  Text(strings.t('app.track.notpriced'), style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchasedBadge extends StatelessWidget {
  final dynamic strings;
  const _PurchasedBadge({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            strings.t('app.track.purchased'),
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final bool dark;
  final bool active;
  final bool enabled;

  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.filled = false,
    this.dark = false,
    this.active = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? Colors.white.withValues(alpha: 0.92)
        : Colors.black.withValues(alpha: 0.4);
    final fg = filled ? Colors.black87 : (active ? Colors.redAccent.shade100 : Colors.white);

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: Icon(icon, size: 18, color: fg),
          ),
        ),
      ),
    );
  }
}

/// Formats a price using the device's locale-aware currency formatting,
/// falling back to a plain "<price> <currency>" string if that fails.
String? formatPrice(double? price, String? currency) {
  if (price == null) return null;
  final symbol = _currencySymbol(currency);
  return '$symbol${price.toStringAsFixed(2)}';
}

String _currencySymbol(String? currency) {
  switch (currency) {
    case 'USD':
      return r'$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'RUB':
      return '₽';
    default:
      return currency != null ? '$currency ' : r'$';
  }
}
