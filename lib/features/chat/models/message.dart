import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String coachId; // ID du coach ou 'user' si c'est l'utilisateur
  
  @HiveField(2)
  final String text;
  
  @HiveField(3)
  final bool isUser;
  
  @HiveField(4)
  final DateTime timestamp;

  Message({
    required this.id,
    required this.coachId,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  Message copyWith({
    String? id,
    String? coachId,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
