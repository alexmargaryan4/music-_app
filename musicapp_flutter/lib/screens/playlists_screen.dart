import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_panel.dart';
import '../widgets/track_card.dart';
import '../widgets/track_detail_sheet.dart';

/// The "Playlists" tab: a grid of the user's named collections, drilling
/// into a per-playlist track view — mirrors the web app's playlists grid
/// and playlist-detail header.
class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  Playlist? _openPlaylist;
  bool _creating = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    // Keep the open playlist reference fresh after edits (rename/track add/remove).
    if (_openPlaylist != null) {
      final refreshed = library.getPlaylist(_openPlaylist!.id);
      if (refreshed == null) {
        _openPlaylist = null;
      } else {
        _openPlaylist = refreshed;
      }
    }

    return _openPlaylist == null ? _buildGrid(context, library) : _buildDetail(context, library, _openPlaylist!);
  }

  Widget _buildGrid(BuildContext context, LibraryProvider library) {
    final strings = context.watch<SettingsProvider>().strings;
    final colors = context.colors;
    final playlists = library.playlists;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(strings.t('nav.playlists'), style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return _NewPlaylistCard(
                    creating: _creating,
                    controller: _nameController,
                    onStart: () => setState(() => _creating = true),
                    onCancel: () => setState(() {
                      _creating = false;
                      _nameController.clear();
                    }),
                    onSubmit: () async {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      if (library.playlistNameTaken(name)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.t('playlist.nameTaken'))),
                        );
                        return;
                      }
                      await library.createPlaylist(name);
                      _nameController.clear();
                      setState(() => _creating = false);
                    },
                  );
                }
                final playlist = playlists[index - 1];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  columnCount: 2,
                  child: ScaleAnimation(
                    scale: 0.94,
                    child: FadeInAnimation(
                      child: _PlaylistCard(
                        playlist: playlist,
                        onTap: () => setState(() => _openPlaylist = playlist),
                        onDelete: () async {
                          final confirmed = await _confirmDelete(context, strings);
                          if (confirmed) await library.deletePlaylist(playlist.id);
                        },
                      ),
                    ),
                  ),
                );
              },
              childCount: playlists.length + 1,
            ),
          ),
        ),
        if (playlists.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: EmptyState(icon: Icons.queue_music_rounded, message: strings.t('playlist.empty')),
            ),
          ),
      ],
    );
  }

  Widget _buildDetail(BuildContext context, LibraryProvider library, Playlist playlist) {
    final strings = context.watch<SettingsProvider>().strings;
    final colors = context.colors;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => setState(() => _openPlaylist = null),
                ),
                Expanded(
                  child: Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: colors.text1, size: 20),
                  onPressed: () => _renamePlaylist(context, library, playlist, strings),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: colors.text1, size: 20),
                  onPressed: () async {
                    final confirmed = await _confirmDelete(context, strings);
                    if (confirmed) {
                      await library.deletePlaylist(playlist.id);
                      setState(() => _openPlaylist = null);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (playlist.tracks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(icon: Icons.music_note_rounded, message: strings.t('playlist.tracksEmpty')),
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
                  final track = playlist.tracks[index];
                  return TrackCard(
                    track: track,
                    removeMode: true,
                    onTap: () => showTrackDetail(context, track),
                    onRemoveFromPlaylist: () => library.removeTrackFromPlaylist(playlist.id, track.trackId),
                  );
                },
                childCount: playlist.tracks.length,
              ),
            ),
          ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, dynamic strings) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('playlist.delete')),
        content: Text(strings.t('playlist.deleteConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.t('app.purchase.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.t('playlist.delete'))),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _renamePlaylist(
    BuildContext context,
    LibraryProvider library,
    Playlist playlist,
    dynamic strings,
  ) async {
    final controller = TextEditingController(text: playlist.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('playlist.rename')),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.t('app.purchase.cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(strings.t('playlist.rename')),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != playlist.name) {
      await library.renamePlaylist(playlist.id, newName);
      setState(() {});
    }
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PlaylistCard({required this.playlist, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.queue_music_rounded, size: 30, color: colors.text1),
                const SizedBox(height: 12),
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${playlist.trackCount} ${strings.t('playlist.tracksLabel')}',
                  style: TextStyle(color: colors.text2, fontSize: 12),
                ),
              ],
            ),
            Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                icon: Icon(Icons.close_rounded, size: 16, color: colors.text2),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPlaylistCard extends StatelessWidget {
  final bool creating;
  final TextEditingController controller;
  final VoidCallback onStart;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _NewPlaylistCard({
    required this.creating,
    required this.controller,
    required this.onStart,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;

    if (!creating) {
      return GestureDetector(
        onTap: onStart,
        child: DottedBorderBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 28, color: colors.text1),
              const SizedBox(height: 8),
              Text(strings.t('playlist.newPlaylist'), style: TextStyle(color: colors.text1, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return GlassPanel(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: strings.t('playlist.namePlaceholder'),
              border: InputBorder.none,
              counterText: '',
              isDense: true,
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: Text(strings.t('app.purchase.cancel'))),
              FilledButton(onPressed: onSubmit, child: Text(strings.t('playlist.create'))),
            ],
          ),
        ],
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor, width: 1.5),
      ),
      child: child,
    );
  }
}
