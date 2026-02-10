import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../../coach/providers/coach_provider.dart';
import '../../coach/models/coach.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String coachId;

  const ChatScreen({super.key, required this.coachId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(Coach coach) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatProvider(widget.coachId).notifier).sendMessage(text, coach);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.coachId));
    final coachesAsync = ref.watch(coachesProvider);
    final coach = coachesAsync.value?.firstWhere((c) => c.id == widget.coachId, orElse: () => Coach(id: '', name: 'Unknown', description: '', systemPrompt: '', avatarIcon: ''));

    if (coach == null || coach.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Coach introuvable')),
      );
    }

    // Auto-scroll when new message arrives or typing starts
    ref.listen(chatProvider(widget.coachId), (previous, next) {
      if (next.messages.value?.length != previous?.messages.value?.length || next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.black, // Force Black
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white), // White Icon
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                coach.avatarIcon.isNotEmpty ? coach.avatarIcon : coach.name[0],
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.name,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                chatState.isTyping
                  ? Text(
                      'écrit...',
                      style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms)
                  : Text(
                      'En ligne', 
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                    ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.moreVertical, color: Theme.of(context).colorScheme.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Text(coach.avatarIcon, style: const TextStyle(fontSize: 40)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Dites bonjour à ${coach.name} !',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      ],
                    ).animate().fadeIn().scale(),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length + (chatState.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && chatState.isTyping) {
                      return _buildTypingIndicator(context);
                    }
                    final message = messages[index];
                    return _buildMessageBubble(context, message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
          _buildInputArea(context, coach),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, message) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? theme.colorScheme.primary 
              : theme.cardTheme.color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.poppins(
                color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: GoogleFonts.poppins(
                color: isUser ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(context, 0),
            const SizedBox(width: 4),
            _dot(context, 1),
            const SizedBox(width: 4),
            _dot(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _dot(BuildContext context, int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(delay: (index * 200).ms, duration: 600.ms, begin: const Offset(0.7, 0.7), end: const Offset(1.2, 1.2));
  }

  Widget _buildInputArea(BuildContext context, Coach coach) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      // Glassmorphism background for input area
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(coach),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.smile, color: Colors.grey[500], size: 20),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _sendMessage(coach),
              icon: const Icon(LucideIcons.send, size: 20),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
