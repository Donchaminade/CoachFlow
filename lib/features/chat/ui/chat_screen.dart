import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../coach/providers/coach_provider.dart';
import '../../coach/models/coach.dart';
import '../models/message.dart';
import '../data/message_repository.dart';
import '../data/tts_service.dart';
import '../../sharing/ui/share_conversation_dialog.dart';
import '../../sharing/ui/share_with_contact_dialog.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String coachId;

  const ChatScreen({super.key, required this.coachId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _ttsService = TtsService();
  String? _currentPlayingMessageId;
  
  // Selection mode for deleting messages
  bool _selectionMode = false;
  final Set<String> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    // Trigger smart welcome if chat is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndInitializeChat();
    });
  }

  void _checkAndInitializeChat() {
    final coaches = ref.read(coachesProvider).valueOrNull;
    final coach = coaches?.firstWhere((c) => c.id == widget.coachId, orElse: () => Coach.empty());
    
    if (coach != null && coach.id.isNotEmpty) {
      final locale = ref.read(localeProvider);
      ref.read(chatProvider(widget.coachId).notifier).initializeChat(coach, locale: locale);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(Coach coach) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final locale = ref.read(localeProvider);
      ref.read(chatProvider(widget.coachId).notifier).sendMessage(text, coach, locale: locale);
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

  void _toggleTts(String messageId, String text) async {
    if (_currentPlayingMessageId == messageId) {
      // Stop if already playing this message
      await _ttsService.stop();
      setState(() => _currentPlayingMessageId = null);
    } else {
      // Start playing this message
      await _ttsService.speak(text, messageId);
      setState(() => _currentPlayingMessageId = messageId);
    }
  }

  void _toggleSelectionMode(String messageId) {
    setState(() {
      if (_selectionMode) {
        // Already in selection mode, toggle this message
        if (_selectedMessageIds.contains(messageId)) {
          _selectedMessageIds.remove(messageId);
          // Exit selection mode if no messages selected
          if (_selectedMessageIds.isEmpty) {
            _selectionMode = false;
          }
        } else {
          _selectedMessageIds.add(messageId);
        }
      } else {
        // Enter selection mode
        _selectionMode = true;
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  // Long press actions
  void _showMessageActions(BuildContext context, Message message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionTile(
              context,
              icon: LucideIcons.copy,
              label: "Copier",
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
            _actionTile(
              context,
              icon: LucideIcons.trash2,
              label: "Supprimer",
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteMessage(message);
              },
            ),
            _actionTile(
              context,
              icon: LucideIcons.mic,
              label: "Vocal",
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Bientôt",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[700],
                  ),
                ),
              ),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
    Widget? trailing,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? (color ?? Theme.of(context).iconTheme.color) : Colors.grey,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: enabled ? (color ?? Theme.of(context).textTheme.bodyLarge?.color) : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  void _copyMessage(Message message) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Message copié",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Supprimer le message ?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Cette action est irréversible.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Annuler",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(message);
            },
            child: Text(
              "Supprimer",
              style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Message message) async {
    try {
      // Delete from repository
      final messageRepo = MessageRepository();
      await messageRepo.deleteMessage(message.id);
      
      // Refresh the chat to update UI
      ref.invalidate(chatProvider(widget.coachId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Message supprimé",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("❌ Error deleting message: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors de la suppression",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedMessages() async {
    // TODO: Implement deletion via repository
    final idsToDelete = _selectedMessageIds.toList();
    print("🗑️ Deleting messages: $idsToDelete");
    
    // For now, just clear selection
    _cancelSelection();
    
    // TODO: Call repository.deleteMessages(idsToDelete) and refresh
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
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
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
            icon: const Icon(LucideIcons.send, color: Colors.white), // Direct Share Icon
            tooltip: 'Envoyer à un contact',
            onPressed: () {
              final authService = ref.read(authServiceProvider);
              if (!authService.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connexion requise pour partager')),
                );
                return;
              }

              final messages = chatState.messages.value ?? [];
              if (messages.isEmpty) return;

              showDialog(
                context: context,
                builder: (context) => ShareWithContactDialog(
                  coach: coach,
                  messages: messages,
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(LucideIcons.share2, color: Colors.white),
            onPressed: () {
              final authService = ref.read(authServiceProvider);
              if (!authService.isAuthenticated) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Connexion requise',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    content: Text(
                      'Vous devez être connecté pour partager une conversation.',
                      style: GoogleFonts.poppins(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/auth');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(
                          'Se connecter',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                return;
              }

              final messages = chatState.messages.value ?? [];
              if (messages.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => ShareConversationDialog(
                    coach: coach,
                    messages: messages,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aucun message à partager',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
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

  Widget _buildMessageBubble(BuildContext context, Message message) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageActions(context, message),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser 
                ? (Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF6366F1) // Indigo for dark mode
                    : theme.colorScheme.primary) 
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
              // Message content - Markdown for AI, Text for User
              if (isUser)
                Text(
                  message.text,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                )
              else
                MarkdownBody(
                  data: message.text,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.poppins(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    strong: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    em: GoogleFonts.poppins(fontStyle: FontStyle.italic),
                    code: GoogleFonts.robotoMono(
                      backgroundColor: Colors.grey.shade200,
                      fontSize: 14,
                    ),
                  ),
                ),
              // Bottom row with timestamp and TTS button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: GoogleFonts.poppins(
                        color: isUser ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ),
                  // TTS button for AI messages only - Prominent style
                  if (!isUser)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _currentPlayingMessageId == message.id 
                              ? LucideIcons.volume2 
                              : LucideIcons.volume,
                          size: 20,
                        ),
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () => _toggleTts(message.id, message.text),
                      ),
                    ),
                ],
              ),
            ],
          ),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black,
                      ),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: Icon(
                LucideIcons.send,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black 
                    : Colors.white,
                size: 20,
              ),
              onPressed: () => _sendMessage(coach),
            ),
          ),
        ],
      ),
    );
  }
}
