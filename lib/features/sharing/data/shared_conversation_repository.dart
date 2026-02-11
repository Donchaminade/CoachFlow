import 'package:hive_flutter/hive_flutter.dart';
import '../models/shared_conversation.dart';

class SharedConversationRepository {
  static const String boxName = 'shared_conversations';

  Future<Box<SharedConversation>> get _box async =>
      await Hive.openBox<SharedConversation>(boxName);

  Future<List<SharedConversation>> getAllShared() async {
    final box = await _box;
    return box.values.toList()..sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
  }

  Future<SharedConversation?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> saveShared(SharedConversation shared) async {
    final box = await _box;
    await box.put(shared.id, shared);
    print("✅ Shared conversation saved: ${shared.id}");
  }

  Future<void> deleteShared(String id) async {
    final box = await _box;
    await box.delete(id);
    print("🗑️ Shared conversation deleted: $id");
  }

  Future<int> getCount() async {
    final box = await _box;
    return box.length;
  }
}
