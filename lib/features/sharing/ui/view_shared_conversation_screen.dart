import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/shared_conversation.dart';
import '../../../core/widgets/app_drawer.dart';

class ViewSharedConversationScreen extends ConsumerWidget {
  final String shareId;

  const ViewSharedConversationScreen({
    super.key,
    required this.shareId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load the shared conversation from repository by ID
    // For now, return a placeholder
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Conversation partagée',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            tooltip: 'Forker la conversation',
            onPressed: () {
              // TODO: Fork conversation to user's own chats
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Conversation ajoutée à vos chats !',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.share2,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Vue de la conversation partagée',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $shareId',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cette fonctionnalité sera bientôt disponible',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
