import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/shared_conversation_repository.dart';
import '../providers/shared_conversation_provider.dart';

class EnterShareCodeDialog extends ConsumerStatefulWidget {
  const EnterShareCodeDialog({super.key});

  @override
  ConsumerState<EnterShareCodeDialog> createState() => _EnterShareCodeDialogState();
}

class _EnterShareCodeDialogState extends ConsumerState<EnterShareCodeDialog> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      setState(() => _error = 'Veuillez entrer un code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = SharedConversationRepository();
      final conversation = await repository.getById(code);

      if (conversation != null) {
        if (mounted) {
          Navigator.pop(context);
          // Refresh the shared conversations list
          ref.invalidate(sharedConversationsProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Conversation chargée avec succès !',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to shared conversations screen
          context.pushNamed('shared-conversations');
        }
      } else {
        setState(() {
          _error = 'Code invalide ou conversation introuvable';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement';
        _isLoading = false;
      });
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
                  LucideIcons.download,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Accéder à une conversation',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Entrez le code de partage',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Ex: ABC12345',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error,
                prefixIcon: const Icon(LucideIcons.hash),
              ),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              onSubmitted: (_) => _loadConversation(),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, size: 20, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Le code vous a été envoyé par la personne qui a partagé la conversation',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadConversation,
                icon: _isLoading
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
                    : const Icon(LucideIcons.download),
                label: Text(
                  _isLoading ? 'Chargement...' : 'Charger la conversation',
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
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Annuler',
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
