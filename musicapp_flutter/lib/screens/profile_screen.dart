import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../state/library_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/glass_panel.dart';

/// The "Profile" tab. There is no server or real account — this is a
/// purely local profile (name/bio/avatar) plus preferences (theme,
/// language) and a data export/clear section, mirroring the shape of the
/// web app's `/profile` page minus anything account-related (password,
/// linked OAuth provider, login history).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settings = context.watch<SettingsProvider>();
    final library = context.watch<LibraryProvider>();
    final strings = settings.strings;
    final profile = settings.profile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Text(strings.t('profile.title'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _editProfile(context, settings, strings),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: colors.text0.withValues(alpha: 0.08),
                      backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                      child: profile.avatarPath == null
                          ? Text(
                              (profile.username.isNotEmpty ? profile.username[0] : '?').toUpperCase(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.bg0, width: 2),
                        ),
                        child: Icon(Icons.edit_rounded, size: 14, color: colors.accentContrast),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(profile.username, style: Theme.of(context).textTheme.titleLarge),
              if ((profile.bio ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(profile.bio!, style: TextStyle(color: colors.text1), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 6),
              Text(
                '${strings.t('profile.memberSince')} ${DateFormat.yMMMd().format(profile.createdAt)}',
                style: TextStyle(color: colors.text2, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _StatCard(label: strings.t('profile.stats.favorites'), value: '${library.favoritesCount}')),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: strings.t('profile.stats.purchases'), value: '${library.purchaseHistory.length}')),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: strings.t('profile.stats.playlists'), value: '${library.playlistsCount}')),
          ],
        ),
        const SizedBox(height: 28),
        Text(strings.t('profile.preferences.title'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GlassPanel(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.palette_outlined, color: colors.text1),
                title: Text(strings.t('profile.preferences.theme')),
                trailing: DropdownButton<String>(
                  value: profile.preferredTheme,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'system', child: Text(strings.t('theme.system'))),
                    DropdownMenuItem(value: 'light', child: Text(strings.t('theme.light'))),
                    DropdownMenuItem(value: 'dark', child: Text(strings.t('theme.dark'))),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setTheme(value);
                  },
                ),
              ),
              Divider(height: 1, color: colors.borderColor),
              ListTile(
                leading: Icon(Icons.language_rounded, color: colors.text1),
                title: Text(strings.t('profile.preferences.language')),
                trailing: DropdownButton<String>(
                  value: profile.preferredLanguage,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'en', child: Text(strings.t('lang.en'))),
                    DropdownMenuItem(value: 'ru', child: Text(strings.t('lang.ru'))),
                    DropdownMenuItem(value: 'hy', child: Text(strings.t('lang.hy'))),
                  ],
                  onChanged: (value) {
                    if (value != null) settings.setLanguage(value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          strings.t('profile.dangerZone.title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.danger),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          borderRadius: 18,
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.download_outlined, color: colors.text1),
                title: Text(strings.t('profile.dangerZone.export')),
                subtitle: Text(strings.t('profile.dangerZone.exportHint'), style: const TextStyle(fontSize: 12)),
                onTap: () => _exportData(context, library, strings),
              ),
              Divider(height: 1, color: colors.borderColor),
              ListTile(
                leading: Icon(Icons.delete_forever_rounded, color: colors.danger),
                title: Text(strings.t('profile.dangerZone.deleteAll'), style: TextStyle(color: colors.danger)),
                subtitle: Text(strings.t('profile.dangerZone.deleteHint'), style: const TextStyle(fontSize: 12)),
                onTap: () => _confirmClearAll(context, library, strings),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context, SettingsProvider settings, dynamic strings) async {
    final usernameController = TextEditingController(text: settings.profile.username);
    final bioController = TextEditingController(text: settings.profile.bio ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = sheetContext.colors;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('profile.editProfile.title'), style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: strings.t('profile.editProfile.username')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLength: 160,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: strings.t('profile.editProfile.bio'),
                    hintText: strings.t('profile.editProfile.bioPlaceholder'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await settings.updateProfile(
                        username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
                        bio: bioController.text.trim(),
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: Text(strings.t('profile.editProfile.save')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, LibraryProvider library, dynamic strings) async {
    try {
      final data = library.exportData();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/musicapp-export.json');
      await file.writeAsString(jsonStr);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.t('profile.dangerZone.export')}: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export failed.')));
      }
    }
  }

  Future<void> _confirmClearAll(BuildContext context, LibraryProvider library, dynamic strings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('profile.dangerZone.deleteConfirmTitle')),
        content: Text(strings.t('profile.dangerZone.deleteConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.t('profile.dangerZone.cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.t('profile.dangerZone.deleteConfirmButton')),
          ),
        ],
      ),
    );
    if (confirmed == true) await library.clearAllData();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassPanel(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: colors.text2, fontSize: 11)),
        ],
      ),
    );
  }
}
