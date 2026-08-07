import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../state/chat_provider.dart';
import '../state/library_provider.dart';
import '../state/search_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_panel.dart';
import '../widgets/skeleton_grid.dart';
import '../widgets/track_card.dart';
import '../widgets/track_detail_sheet.dart';
import '../widgets/playlist_picker_sheet.dart';

/// The "Search" tab — the app's home screen. Mirrors the web app's `/app`
/// search hero + result grid.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch() {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    context.read<SearchProvider>().search(term);
    context.read<ChatProvider>().setLastSearchTerm(term);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;
    final search = context.watch<SearchProvider>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('nav.home'), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  strings.t('app.search.subtitle'),
                  style: TextStyle(color: colors.text1),
                ),
                const SizedBox(height: 18),
                GlassPanel(
                  strong: true,
                  borderRadius: 999,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.search_rounded, color: colors.text2, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _runSearch(),
                          decoration: InputDecoration(
                            hintText: strings.t('app.search.placeholder'),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.accentContrast,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        onPressed: _runSearch,
                        child: Text(strings.t('app.search.button')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildContent(context, search, strings),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SearchProvider search, dynamic strings) {
    if (search.status == SearchStatus.loading) {
      return const SliverToBoxAdapter(child: SkeletonGrid());
    }

    if (!search.hasSearched) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(icon: Icons.search_rounded, message: strings.t('app.search.empty')),
      );
    }

    if (search.results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(icon: Icons.music_off_rounded, message: strings.t('app.search.noresults')),
      );
    }

    return SliverPadding(
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
            final track = search.results[index];
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
          childCount: search.results.length,
        ),
      ),
    );
  }
}
