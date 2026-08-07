import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/ambient_background.dart';
import '../widgets/mini_player_bar.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';
import 'playlists_screen.dart';
import 'profile_screen.dart';
import 'recent_screen.dart';
import 'search_screen.dart';

/// Hosts the five main tabs (Search, Favorites, Playlists, Recent, Chat)
/// plus Profile behind a bottom navigation bar, with the ambient
/// background and mini-player floating above every tab — mirrors the web
/// app's persistent navbar + mini-player across `/app` and `/chat`.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    SearchScreen(),
    FavoritesScreen(),
    PlaylistsScreen(),
    RecentScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: colors.surface.withValues(alpha: 0.92),
            indicatorColor: colors.accent.withValues(alpha: 0.14),
            elevation: 0,
            height: 64,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.search_rounded),
                label: strings.t('nav.home'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: library.favoritesCount > 0,
                  label: Text('${library.favoritesCount}'),
                  child: const Icon(Icons.favorite_border_rounded),
                ),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: strings.t('nav.favorites'),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: library.playlistsCount > 0,
                  label: Text('${library.playlistsCount}'),
                  child: const Icon(Icons.queue_music_outlined),
                ),
                selectedIcon: const Icon(Icons.queue_music_rounded),
                label: strings.t('nav.playlists'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                label: strings.t('nav.recent'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_awesome_rounded),
                label: strings.t('nav.chat'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: strings.t('nav.profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
