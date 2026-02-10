import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';

class MessageRepository {
  static const String boxName = 'messages';

  Future<Box<Message>> get _box async => await Hive.openBox<Message>(boxName);

  Future<List<Message>> getMessagesForCoach(String coachId) async {
    final box = await _box;
    // Filter messages for this coach
    // Note: In a real app with many messages, we'd use a better query or separate boxes
    return box.values.where((m) => m.coachId == coachId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> addMessage(Message message) async {
    final box = await _box;
    await box.put(message.id, message);
  }
  
  Future<void> deleteMessagesForCoach(String coachId) async {
    final box = await _box;
    final keysToDelete = box.values
        .where((m) => m.coachId == coachId)
        .map((m) => m.id)
        .toList(); // Assuming ID is the key, but Hive keys might suffice if we used consistent keys
    
    // Actually, let's just create a list of keys to delete
     final Map<dynamic, Message> map = box.toMap();
     final keys = <dynamic>[];
     map.forEach((key, value) {
       if (value.coachId == coachId) {
         keys.add(key);
       }
     });
     
     await box.deleteAll(keys);
  }

  Future<Set<String>> getActiveCoachIds() async {
    final box = await _box;
    return box.values.map((m) => m.coachId).toSet();
  }
}
