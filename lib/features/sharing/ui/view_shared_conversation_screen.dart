import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/shared_conversation.dart';
import '../../coach/data/coach_repository.dart';
import '../../coach/models/coach.dart';
import '../../coach/providers/coach_provider.dart';
import '../../chat/data/message_repository.dart';
import '../../chat/providers/chat_provider.dart';
import '../providers/shared_conversation_provider.dart';
import '../../../core/widgets/app_drawer.dart';

class ViewSharedConversationScreen extends ConsumerStatefulWidget {
  final String shareId;
  final SharedConversation? initialConversation;

  const ViewSharedConversationScreen({
    super.key,
    required this.shareId,
    this.initialConversation,
  });

  @override
  ConsumerState<ViewSharedConversationScreen> createState() => _ViewSharedConversationScreenState();
}

class _ViewSharedConversationScreenState extends ConsumerState<ViewSharedConversationScreen> {
  SharedConversation? _conversation;
  bool _isLoading = true;
  bool _isImporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    if (widget.initialConversation != null) {
      setState(() {
        _conversation = widget.initialConversation;
        _isLoading = false;
      });
      return;
    }

    try {
      final sharingService = ref.read(supabaseSharingServiceProvider);
      final conversation = await sharingService.downloadConversation(widget.shareId);
      
      if (mounted) {
        setState(() {
          _conversation = conversation;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Impossible de charger la conversation';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueConversation() async {
    if (_conversation == null) return;
    
    setState(() => _isImporting = true);
    
    try {
      final coachRepo = ref.read(coachRepositoryProvider); // You might need a provider for this
      final messageRepo = ref.read(messageRepositoryProvider);
      
      // 1. Find or Create Coach
      final allCoaches = await coachRepo.getAllCoaches();
      Coach? targetCoach;
      
      // Try to find matching coach by name
      try {
        targetCoach = allCoaches.firstWhere((c) => c.name == _conversation!.coach.name);
      } catch (_) {
        // Not found
      }
      
        if (targetCoach == null) {
        // Create new coach
        final newId = const Uuid().v4();
        targetCoach = _conversation!.coach.copyWith(
          id: newId,
          systemPrompt: "Tu es ${_conversation!.coach.name}. Agis comme tel.",
        );
        await coachRepo.addCoach(targetCoach!); // Ensure this method exists and is public
      }
      
      // 2. Import Messages
      for (var msg in _conversation!.messages) {
        // Create a copy with the correct coachId and a new ID to avoid collisions
        // (though collisions are unlikely with UUIDs, safer to regenerate or keep if unique)
        // We'll keep the ID if it doesn't exist, or generate new ones?
        // Let's keep original content but ensure coachId matches
        
        final newMsg = msg.copyWith(
          coachId: targetCoach!.id,
          // We can keep original ID or generate new. 
          // If we imported this before, we might duplicate messages if we generate new IDs.
          // Let's use the original ID from the share to prevent duplicates if imported twice.
          id: msg.id, 
        );
        
        await messageRepo.addMessage(newMsg);
      }
      
      if (mounted) {
        setState(() => _isImporting = false);
        
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conversation importée avec succès !',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to the chat
        context.push('/chat/${targetCoach!.id}');
      }
      
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'importation: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(backgroundColor: Colors.black, title: const Text('')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _conversation == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Conversation introuvable', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }
    
    final coach = _conversation!.coach;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
               backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(coach.avatarIcon.isNotEmpty ? coach.avatarIcon : coach.name[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.name,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Partagé par ${_conversation!.sharedBy}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _conversation!.messages.length,
              itemBuilder: (context, index) {
                final message = _conversation!.messages[index];
                final isUser = message.isUser;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Text(coach.avatarIcon.isNotEmpty ? coach.avatarIcon : '🤖'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              topLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                              topRight: !isUser ? const Radius.circular(16) : const Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: GoogleFonts.poppins(
                              color: isUser 
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      
                      if (isUser) ...[
                         const SizedBox(width: 8),
                         const CircleAvatar(
                          radius: 16,
                          child: Icon(LucideIcons.user, size: 16),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isImporting ? null : _continueConversation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isImporting 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white))
                      : const Icon(LucideIcons.messageSquarePlus),
                  label: Text(
                    _isImporting ? 'Importation...' : 'Continuer la discussion',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
