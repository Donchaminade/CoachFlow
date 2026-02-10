import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_context.dart';

class UserContextRepository {
  static const String boxName = 'user_context';
  static const String key = 'current_context';

  Future<Box<UserContext>> get _box async => await Hive.openBox<UserContext>(boxName);

  Future<UserContext> getContext() async {
    final box = await _box;
    return box.get(key) ?? UserContext();
  }

  Future<void> saveContext(UserContext context) async {
    final box = await _box;
    await box.put(key, context);
  }
}
