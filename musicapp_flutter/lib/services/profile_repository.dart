import '../models/user_profile.dart';
import 'storage_service.dart';

/// Local persistence for the single on-device "profile". There is only
/// ever one profile (no accounts), stored under a fixed key.
class ProfileRepository {
  static const String _key = 'profile';

  UserProfile getProfile() {
    final box = StorageService.profile;
    var profile = box.get(_key);
    if (profile == null) {
      profile = UserProfile();
      box.put(_key, profile);
    }
    return profile;
  }

  Future<void> updateProfile({String? username, String? bio}) async {
    final profile = getProfile();
    if (username != null) profile.username = username;
    if (bio != null) profile.bio = bio;
    await profile.save();
  }

  Future<void> updateAvatar(String path) async {
    final profile = getProfile();
    profile.avatarPath = path;
    await profile.save();
  }

  Future<void> updateLanguage(String language) async {
    final profile = getProfile();
    profile.preferredLanguage = language;
    await profile.save();
  }

  Future<void> updateTheme(String theme) async {
    final profile = getProfile();
    profile.preferredTheme = theme;
    await profile.save();
  }
}
