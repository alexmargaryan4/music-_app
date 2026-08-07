import 'package:hive/hive.dart';

part 'user_profile.g.dart';

/// A purely local "profile" — there is no server, no accounts and no real
/// authentication. This just lets the person set a display name, a short
/// bio and an avatar, matching the look of the web app's profile page.
@HiveType(typeId: 4)
class UserProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String? bio;

  @HiveField(2)
  String? avatarPath;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  String preferredLanguage;

  @HiveField(5)
  String preferredTheme; // "light" | "dark" | "system"

  UserProfile({
    this.username = 'You',
    this.bio,
    this.avatarPath,
    DateTime? createdAt,
    this.preferredLanguage = 'en',
    this.preferredTheme = 'system',
  }) : createdAt = createdAt ?? DateTime.now();
}
