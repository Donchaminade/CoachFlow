import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../coach/providers/coach_provider.dart';
import '../../coach/models/coach.dart';
import '../providers/chat_provider.dart';

// Provider to get active coaches only
final historyCoachesProvider = FutureProvider<List<Coach>>((ref) async {
  final messageRepo = ref.read(messageRepositoryProvider);
  final activeIds = await messageRepo.getActiveCoachIds();
  
  final allCoaches = await ref.read(coachesProvider.future);
  return allCoaches.where((c) => activeIds.contains(c.id)).toList();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyCoachesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black, // Force Black
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            title: Text(
              "Historique",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
            ),
             actions: [
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.white),
                onPressed: () {
                  // TODO: Clear history feature
                },
              ),
            ],
          ),
          historyAsync.when(
            data: (coaches) {
              if (coaches.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.history, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          "Aucune discussion récente",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final coach = coaches[index];
                    return _buildHistoryItem(context, coach, index);
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

  Widget _buildHistoryItem(BuildContext context, Coach coach, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          coach.avatarIcon.isNotEmpty ? coach.avatarIcon : coach.name[0],
          style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      title: Text(
        coach.name,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        "Derniers échanges...",
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
      ),
      trailing:  Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
      onTap: () => context.pushNamed('chat', pathParameters: {'id': coach.id}),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }
}
