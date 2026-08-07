import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/user_profile.dart';
import '../services/profile_repository.dart';

/// Drives theme mode, language and the local profile. There is no server —
/// everything here is read from / written straight to Hive via
/// [ProfileRepository].
class SettingsProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  late UserProfile _profile;

  SettingsProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository() {
    _profile = _repository.getProfile();
  }

  UserProfile get profile => _profile;

  ThemeMode get themeMode {
    switch (_profile.preferredTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get languageCode => _profile.preferredLanguage;

  AppStrings get strings => AppStrings.of(languageCode);

  Future<void> setTheme(String theme) async {
    await _repository.updateTheme(theme);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    await _repository.updateLanguage(language);
    notifyListeners();
  }

  Future<void> updateProfile({String? username, String? bio}) async {
    await _repository.updateProfile(username: username, bio: bio);
    notifyListeners();
  }

  Future<void> updateAvatar(String path) async {
    await _repository.updateAvatar(path);
    notifyListeners();
  }

  void refresh() {
    _profile = _repository.getProfile();
    notifyListeners();
  }
}
