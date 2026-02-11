import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../network/providers/network_provider.dart';
import '../../network/models/contact.dart';
import '../../chat/models/message.dart';
import '../../coach/models/coach.dart';
import '../data/supabase_sharing_service.dart';
import '../providers/shared_conversation_provider.dart';

class ShareWithContactDialog extends ConsumerStatefulWidget {
  final Coach coach;
  final List<Message> messages;

  const ShareWithContactDialog({
    super.key,
    required this.coach,
    required this.messages,
  });

  @override
  ConsumerState<ShareWithContactDialog> createState() => _ShareWithContactDialogState();
}

class _ShareWithContactDialogState extends ConsumerState<ShareWithContactDialog> {
  bool _isLoading = false;

  Future<void> _shareWithContact(Contact contact) async {
    setState(() => _isLoading = true);
    
    try {
      final shareId = const Uuid().v4().substring(0, 8); // Short ID
      final sharingService = ref.read(supabaseSharingServiceProvider);
      
      await sharingService.uploadConversation(
        shareId: shareId,
        coachName: widget.coach.name,
        coachAvatar: widget.coach.avatarIcon,
        messages: widget.messages,
        title: 'Conversation avec ${widget.coach.name}',
        recipientId: contact.contactId, // DIRECT SHARE
      );
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Envoyé à ${contact.name} !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Envoyer à...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 300,
                child: contactsAsync.when(
                  data: (contacts) {
                    if (contacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun contact',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/network');
                              },
                              child: const Text('Ajouter des contacts'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(contact.avatarEmoji),
                          ),
                          title: Text(contact.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(contact.email, style: GoogleFonts.poppins(fontSize: 12)),
                          trailing: const Icon(LucideIcons.send, size: 16),
                          onTap: () => _shareWithContact(contact),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erreur: $err')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
