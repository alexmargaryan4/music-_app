import '../models/chat_message.dart';
import 'storage_service.dart';

/// Local persistence for the AI chat's message history.
class ChatRepository {
  List<ChatMessageEntry> getHistory() {
    final list = StorageService.chat.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> append(ChatMessageEntry entry) async {
    await StorageService.chat.add(entry);
  }

  Future<void> clear() async {
    await StorageService.chat.clear();
  }
}
