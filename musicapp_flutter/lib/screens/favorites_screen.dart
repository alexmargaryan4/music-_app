import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/playlist_picker_sheet.dart';
import '../widgets/track_card.dart';
import '../widgets/track_detail_sheet.dart';

/// The "Favorites" tab — mirrors the web app's favorites grid.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<SettingsProvider>().strings;
    final library = context.watch<LibraryProvider>();
    final favorites = library.favorites;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(strings.t('favorites.title'), style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
        if (favorites.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(icon: Icons.favorite_border_rounded, message: strings.t('favorites.empty')),
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
                  final track = favorites[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      scale: 0.94,
                      child: FadeInAnimation(
                        child: TrackCard(
                          track: track,
                          onTap: () => showTrackDetail(context, track),
                          onAddToPlaylist: () => showPlaylistPicker(context, track),
                        ),
                      ),
                    ),
                  );
                },
                childCount: favorites.length,
              ),
            ),
          ),
      ],
    );
  }
}
