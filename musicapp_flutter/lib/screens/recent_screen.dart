import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/empty_state.dart';
import '../widgets/playlist_picker_sheet.dart';
import '../widgets/track_card.dart';
import '../widgets/track_detail_sheet.dart';

/// The "Recent" tab — recently-played tracks, newest first, with a
/// "Clear" action — mirrors the web app's recent view.
class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<SettingsProvider>().strings;
    final colors = context.colors;
    final library = context.watch<LibraryProvider>();
    final recent = library.recent;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(strings.t('nav.recent'), style: Theme.of(context).textTheme.headlineMedium),
                ),
                if (recent.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _confirmClear(context, library, strings),
                    icon: Icon(Icons.delete_sweep_outlined, size: 18, color: colors.text1),
                    label: Text(strings.t('recent.clear'), style: TextStyle(color: colors.text1)),
                  ),
              ],
            ),
          ),
        ),
        if (recent.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(icon: Icons.history_rounded, message: strings.t('recent.empty')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = recent[index].track;
                  return TrackCard(
                    track: track,
                    onTap: () => showTrackDetail(context, track),
                    onAddToPlaylist: () => showPlaylistPicker(context, track),
                  );
                },
                childCount: recent.length,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, LibraryProvider library, dynamic strings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('recent.clear')),
        content: Text(strings.t('recent.clearConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.t('app.purchase.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.t('recent.clear'))),
        ],
      ),
    );
    if (confirmed == true) await library.clearRecent();
  }
}
