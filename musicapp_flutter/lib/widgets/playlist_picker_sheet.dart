import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';

/// Bottom sheet listing the user's playlists with a checkmark for ones the
/// track is already in, plus an inline "create new playlist" field —
/// mirrors the web app's `#playlist-picker` popover.
Future<void> showPlaylistPicker(BuildContext context, Track track) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PlaylistPickerSheet(track: track),
  );
}

class _PlaylistPickerSheet extends StatefulWidget {
  final Track track;
  const _PlaylistPickerSheet({required this.track});

  @override
  State<_PlaylistPickerSheet> createState() => _PlaylistPickerSheetState();
}

class _PlaylistPickerSheetState extends State<_PlaylistPickerSheet> {
  final _controller = TextEditingController();
  final Set<String> _justAdded = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final library = context.watch<LibraryProvider>();
    final strings = context.watch<SettingsProvider>().strings;
    final playlists = library.playlists;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.text2.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(strings.t('playlist.addToPlaylist'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  strings.t('playlist.empty'),
                  style: TextStyle(color: colors.text2),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final inPlaylist = _justAdded.contains(playlist.id) ||
                        playlist.tracks.any((t) => t.trackId == widget.track.trackId);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.queue_music_rounded, color: colors.text1),
                      title: Text(playlist.name),
                      subtitle: Text('${playlist.trackCount} ${strings.t('playlist.tracksLabel')}'),
                      trailing: inPlaylist
                          ? Icon(Icons.check_circle_rounded, color: colors.accent)
                          : Icon(Icons.add_circle_outline_rounded, color: colors.text2),
                      onTap: () async {
                        await context.read<LibraryProvider>().addTrackToPlaylist(playlist.id, widget.track);
                        if (!mounted) return;
                        setState(() => _justAdded.add(playlist.id));
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: strings.t('playlist.namePlaceholder'),
                      filled: true,
                      fillColor: colors.text0.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () async {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;
                    if (context.read<LibraryProvider>().playlistNameTaken(name)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.t('playlist.nameTaken'))),
                      );
                      return;
                    }
                    final libraryProvider = context.read<LibraryProvider>();
                    final created = await libraryProvider.createPlaylist(name);
                    if (created != null) {
                      await libraryProvider.addTrackToPlaylist(created.id, widget.track);
                      if (!mounted) return;
                      _controller.clear();
                      setState(() => _justAdded.add(created.id));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
