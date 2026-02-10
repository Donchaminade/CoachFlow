import 'package:hive/hive.dart';

part 'coach.g.dart';

@HiveType(typeId: 0)
class Coach {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String systemPrompt;
  
  @HiveField(4)
  final String avatarIcon; // Stocke un emoji ou icon name pour l'instant

  Coach({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.avatarIcon,
  });
}
