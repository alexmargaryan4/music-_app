import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../state/chat_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/glass_panel.dart';
import '../widgets/playlist_picker_sheet.dart';
import '../widgets/track_card.dart';
import '../widgets/track_detail_sheet.dart';

/// The AI recommendation chat screen — talks to Groq directly from the
/// phone and renders recommended songs as track-card carousels under the
/// assistant's message, mirroring the web app's `/chat` page.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final chat = context.read<ChatProvider>();
    final language = context.read<SettingsProvider>().languageCode;
    _scrollToBottom();
    await chat.sendMessage(text, language: language);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.watch<SettingsProvider>().strings;
    final chat = context.watch<ChatProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t('chat.title'), style: Theme.of(context).textTheme.headlineSmall),
                    Text(strings.t('chat.subtitle'), style: TextStyle(color: colors.text1, fontSize: 12)),
                  ],
                ),
              ),
              if (chat.messages.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: colors.text1),
                  onPressed: () => _confirmClear(context, chat, strings),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: chat.messages.isEmpty ? 1 : chat.messages.length + (chat.thinking ? 1 : 0),
            itemBuilder: (context, index) {
              if (chat.messages.isEmpty) {
                return _WelcomeBubble(text: strings.t('chat.welcome'));
              }
              if (index == chat.messages.length) {
                return _ThinkingBubble(label: strings.t('chat.thinking'));
              }
              final message = chat.messages[index];
              return _MessageBubble(message: message);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: GlassPanel(
              strong: true,
              borderRadius: 999,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: strings.t('chat.placeholder'),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: colors.accent, foregroundColor: colors.accentContrast),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, ChatProvider chat, dynamic strings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('chat.clear')),
        content: Text(strings.t('chat.clearConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.t('app.purchase.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.t('chat.clear'))),
        ],
      ),
    );
    if (confirmed == true) await chat.clearHistory();
  }
}

class _WelcomeBubble extends StatelessWidget {
  final String text;
  const _WelcomeBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassPanel(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          child: Text(text),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  final String label;
  const _ThinkingBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassPanel(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: colors.text2),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: colors.text2)),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntry message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUser = message.isUser;

    final bubble = Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: isUser
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(message.content, style: TextStyle(color: colors.accentContrast)),
              )
            : GlassPanel(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Text(message.content),
              ),
      ),
    );

    final tracks = message.tracks;
    if (tracks == null || tracks.isEmpty) {
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: bubble);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bubble,
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return SizedBox(
                  width: 140,
                  child: TrackCard(
                    track: track,
                    onTap: () => showTrackDetail(context, track),
                    onAddToPlaylist: () => showPlaylistPicker(context, track),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
