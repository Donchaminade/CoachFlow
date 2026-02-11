import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../models/shared_conversation.dart';
import '../data/shared_conversation_repository.dart';
import '../providers/shared_conversation_provider.dart';
import '../../chat/models/message.dart';
import '../../coach/models/coach.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ShareConversationDialog extends ConsumerStatefulWidget {
  final Coach coach;
  final List<Message> messages;

  const ShareConversationDialog({
    super.key,
    required this.coach,
    required this.messages,
  });

  @override
  ConsumerState<ShareConversationDialog> createState() => _ShareConversationDialogState();
}

class _ShareConversationDialogState extends ConsumerState<ShareConversationDialog> {
  final _titleController = TextEditingController();
  bool _isGenerating = false;
  String? _shareCode;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.lock, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text('Connexion requise', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Pour partager des conversations avec d\'autres utilisateurs, vous devez créer un compte.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close auth dialog
              Navigator.pop(context); // Close share dialog
              context.go('/auth'); // Navigate to auth
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
            child: Text('Créer un compte', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateShareCode() async {
    // Check if user is authenticated
    final authService = ref.read(authServiceProvider);
    if (!authService.isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final shareCode = const Uuid().v4().substring(0, 8).toUpperCase();
      
      // Upload to Supabase
      final supabaseService = ref.read(supabaseSharingServiceProvider);
      await supabaseService.uploadConversation(
        shareId: shareCode,
        coachName: widget.coach.name,
        coachAvatar: widget.coach.avatarIcon,
        messages: widget.messages,
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      );

      // Also save locally for offline access
      final userProfile = ref.read(userProfileProvider);
      final sharedConv = SharedConversation(
        id: shareCode,
        sharedBy: userProfile?.name ?? 'Utilisateur',
        coach: widget.coach,
        messages: widget.messages,
        sharedAt: DateTime.now(),
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      );

      final repository = SharedConversationRepository();
      await repository.saveShared(sharedConv);

      setState(() {
        _shareCode = shareCode;
        _isGenerating = false;
      });
    } catch (e) {
      print('❌ Error sharing conversation: $e');
      setState(() => _isGenerating = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyShareCode() {
    if (_shareCode != null) {
      Clipboard.setData(ClipboardData(text: _shareCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Code copié : $_shareCode',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.share2,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Partager la conversation',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_shareCode == null) ...[
              Text(
                'Donnez un titre (optionnel)',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ex: Conseils productivité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateShareCode,
                  icon: _isGenerating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.check),
                  label: Text(
                    _isGenerating ? 'Génération...' : 'Générer le code de partage',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Conversation partagée !',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Code de partage :',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _shareCode!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _copyShareCode,
                  icon: const Icon(LucideIcons.copy),
                  label: Text(
                    'Copier le code',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Fermer',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
