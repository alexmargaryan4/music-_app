import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../screens/lyrics_screen.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import 'playlist_picker_sheet.dart';
import 'purchase_confirm_sheet.dart';

/// Full track detail bottom sheet — artwork, metadata grid, and actions
/// (favorite / add to playlist / lyrics / buy) — mirrors the web app's
/// `#track-modal-body`.
Future<void> showTrackDetail(BuildContext context, Track track) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TrackDetailSheet(track: track),
  );
}

class TrackDetailSheet extends StatelessWidget {
  final Track track;
  const TrackDetailSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;
    final library = context.watch<LibraryProvider>();
    final isFav = library.isFavorite(track.trackId);
    final isPurchased = library.isPurchased(track.trackId);
    final price = _formatPrice(track.effectivePrice, track.currency);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.text2.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: track.artworkUrlHigh != null
                      ? CachedNetworkImage(
                          imageUrl: track.artworkUrlHigh!,
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 220,
                          height: 220,
                          color: colors.text0.withValues(alpha: 0.06),
                          child: Icon(Icons.music_note_rounded, size: 48, color: colors.text2),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                track.trackName ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                track.artistName ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.text1),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 3.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _MetaItem(label: strings.t('app.track.album'), value: track.collectionName ?? '—'),
                  _MetaItem(label: strings.t('app.track.genre'), value: track.primaryGenreName ?? '—'),
                  _MetaItem(label: strings.t('app.track.duration'), value: _formatDuration(track.trackTimeMillis)),
                  _MetaItem(label: strings.t('app.track.released'), value: _formatDate(track.releaseDate)),
                ],
              ),
              if (isPurchased) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: colors.success),
                      const SizedBox(width: 6),
                      Text(strings.t('app.track.purchased'), style: TextStyle(color: colors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    label: isFav ? strings.t('app.track.removeFavorite') : strings.t('app.track.addFavorite'),
                    active: isFav,
                    onTap: () => context.read<LibraryProvider>().toggleFavorite(track),
                  ),
                  _ActionChip(
                    icon: Icons.playlist_add_rounded,
                    label: strings.t('playlist.addToPlaylist'),
                    onTap: () => showPlaylistPicker(context, track),
                  ),
                  _ActionChip(
                    icon: Icons.lyrics_rounded,
                    label: strings.t('app.track.lyrics'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LyricsScreen(track: track)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (track.trackViewUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.accentContrast,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () => showPurchaseConfirmSheet(context, track),
                    child: Text(
                      [
                        if (price != null) price,
                        isPurchased ? strings.t('app.track.buyAgain') : strings.t('app.track.buy'),
                      ].join(' · '),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.text0.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: colors.text2, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.text0, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.12) : colors.text0.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: active ? colors.accent : colors.text1),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? colors.accent : colors.text0,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _formatPrice(double? price, String? currency) {
  if (price == null) return null;
  final symbol = switch (currency) {
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    'RUB' => '₽',
    _ => currency != null ? '$currency ' : r'$',
  };
  return '$symbol${price.toStringAsFixed(2)}';
}

String _formatDuration(int? millis) {
  if (millis == null) return '—';
  final totalSec = (millis / 1000).round();
  final min = totalSec ~/ 60;
  final sec = (totalSec % 60).toString().padLeft(2, '0');
  return '$min:$sec';
}

String _formatDate(String? dateStr) {
  if (dateStr == null) return '—';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat.yMMMd().format(date);
  } catch (_) {
    return dateStr;
  }
}
