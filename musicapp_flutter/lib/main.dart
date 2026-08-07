import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_shell.dart';
import 'services/storage_service.dart';
import 'state/chat_provider.dart';
import 'state/library_provider.dart';
import 'state/player_provider.dart';
import 'state/search_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (context) {
          final player = PlayerProvider();
          // Wire preview playback -> "Recently Played" without the two
          // providers needing to know about each other directly.
          player.onTrackStarted = (track) {
            context.read<LibraryProvider>().recordPlay(track);
          };
          return player;
        }),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'MusicApp',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
