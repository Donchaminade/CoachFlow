import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../coach/providers/coach_provider.dart';
import '../../coach/models/coach.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black, // Force Black
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              "Messages",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white), // White Text
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.edit3, color: Colors.white)),
            ],
          ),
          coachesAsync.when(
            data: (coaches) {
              if (coaches.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text("Aucune conversation", style: GoogleFonts.poppins())),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final coach = coaches[index];
                    return _buildConversationItem(context, coach, index);
                  },
                  childCount: coaches.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Erreur: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, Coach coach, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          coach.avatarIcon.isNotEmpty ? coach.avatarIcon : coach.name[0],
          style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      title: Text(
        coach.name,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        coach.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Now", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          // Optionally add unread badge here
        ],
      ),
      onTap: () => context.pushNamed('chat', pathParameters: {'id': coach.id}),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }
}
