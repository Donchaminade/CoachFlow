import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_context.dart';
import '../data/user_context_repository.dart';

final userContextRepositoryProvider = Provider((ref) => UserContextRepository());

final userContextProvider = StateNotifierProvider<UserContextNotifier, AsyncValue<UserContext>>((ref) {
  return UserContextNotifier(ref.read(userContextRepositoryProvider));
});

class UserContextNotifier extends StateNotifier<AsyncValue<UserContext>> {
  final UserContextRepository _repository;

  UserContextNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadContext();
  }

  Future<void> loadContext() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getContext());
  }

  Future<void> updateContext(UserContext context) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveContext(context);
      return context;
    });
  }
}
