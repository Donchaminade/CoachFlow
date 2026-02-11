import 'package:hive/hive.dart';
import '../../chat/models/message.dart';
import '../../coach/models/coach.dart';

part 'shared_conversation.g.dart';

@HiveType(typeId: 4)
class SharedConversation {
  @HiveField(0)
  final String id; // Unique share code

  @HiveField(1)
  final String sharedBy; // Name of person who shared

  @HiveField(2)
  final Coach coach;

  @HiveField(3)
  final List<Message> messages;

  @HiveField(4)
  final DateTime sharedAt;

  @HiveField(5)
  final String? title; // Optional title for the conversation

  SharedConversation({
    required this.id,
    required this.sharedBy,
    required this.coach,
    required this.messages,
    required this.sharedAt,
    this.title,
  });
}
