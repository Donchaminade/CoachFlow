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
}
