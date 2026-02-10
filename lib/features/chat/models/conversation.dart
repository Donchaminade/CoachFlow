import '../../coach/models/coach.dart';
import 'message.dart';

class Conversation {
  final Coach coach;
  final Message lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const Conversation({
    required this.coach,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}
