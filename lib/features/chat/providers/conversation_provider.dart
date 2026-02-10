import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../coach/providers/coach_provider.dart';
import '../data/message_repository.dart';
import '../models/conversation.dart';

// Provider for conversations list
final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final messageRepo = MessageRepository();
  final activeCoachIds = await messageRepo.getActiveCoachIds();
  
  if (activeCoachIds.isEmpty) {
    return [];
  }
  
  final allCoaches = await ref.watch(coachesProvider.future);
  final conversations = <Conversation>[];
  
  for (final coachId in activeCoachIds) {
    try {
      final messages = await messageRepo.getMessagesForCoach(coachId);
      if (messages.isNotEmpty) {
        final coach = allCoaches.firstWhere(
          (c) => c.id == coachId,
          orElse: () => allCoaches.first, // Fallback if coach not found
        );
        final lastMsg = messages.last;
        conversations.add(Conversation(
          coach: coach,
          lastMessage: lastMsg,
          lastMessageTime: lastMsg.timestamp,
          unreadCount: 0, // TODO: implement unread count logic
        ));
      }
    } catch (e) {
      print("⚠️ Error loading conversation for coach $coachId: $e");
    }
  }
  
  // Sort by most recent first
  conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  
  return conversations;
});
