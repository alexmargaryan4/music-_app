import 'package:hive/hive.dart';
import 'track.dart';

part 'chat_message.g.dart';

/// A single turn in the AI recommendation chat. `role` is "user" or
/// "assistant"; assistant turns may carry recommended [tracks] resolved
/// against iTunes, rendered as track cards under the message bubble.
@HiveType(typeId: 5)
class ChatMessageEntry extends HiveObject {
  @HiveField(0)
  final String role;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final List<Track>? tracks;

  @HiveField(3)
  final DateTime createdAt;

  ChatMessageEntry({
    required this.role,
    required this.content,
    this.tracks,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUser => role == 'user';
}
