import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach.dart';
import '../data/coach_repository.dart';

final coachRepositoryProvider = Provider((ref) => CoachRepository());

final coachesProvider = FutureProvider<List<Coach>>((ref) async {
  final repository = ref.watch(coachRepositoryProvider);
  return repository.getAllCoaches();
});

final coachControllerProvider = StateNotifierProvider<CoachNotifier, AsyncValue<void>>((ref) {
  return CoachNotifier(ref.read(coachRepositoryProvider), ref);
});

class CoachNotifier extends StateNotifier<AsyncValue<void>> {
  final CoachRepository _repository;
  final Ref _ref;

  CoachNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addCoach(Coach coach) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addCoach(coach);
      _ref.invalidate(coachesProvider);
    });
  }

  Future<void> deleteCoach(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteCoach(id);
      _ref.invalidate(coachesProvider);
    });
  }
}
