import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/shared_conversation_provider.dart';
import '../../../core/utils/time_helper.dart';
import 'enter_share_code_dialog.dart';

class SharedConversationsScreen extends ConsumerWidget {
  const SharedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedConvsAsync = ref.watch(sharedConversationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Conversations partagées',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Bottom navbar height + margin
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const EnterShareCodeDialog(),
            );
          },
          icon: const Icon(LucideIcons.download),
          label: Text(
            'Entrer un code',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
      ),
      body: sharedConvsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
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
                    'Aucune conversation partagée',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les conversations que vous recevez\napparaîtront ici',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      conv.coach.avatarIcon.isNotEmpty
                          ? conv.coach.avatarIcon
                          : conv.coach.name[0],
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    conv.title ?? 'Conversation avec ${conv.coach.name}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Partagé par ${conv.sharedBy}',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${conv.messages.length} messages • ${formatRelativeTime(conv.sharedAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  onTap: () {
                    context.push('/home/shared-conversations/${conv.id}');
                  },
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$err',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
