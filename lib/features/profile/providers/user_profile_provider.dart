import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_user.dart';
import '../data/user_profile_repository.dart';

// Repository provider
final userProfileRepositoryProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserProfileRepository(supabase);
});

// Profile provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AppUser?>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  final authUserAsync = ref.watch(currentAuthUserProvider);
  
  return UserProfileNotifier(repository, authUserAsync.value);
});

class UserProfileNotifier extends StateNotifier<AppUser?> {
  final UserProfileRepository _repository;

  UserProfileNotifier(this._repository, AppUser? initialUser) : super(initialUser);

  Future<void> saveProfile(AppUser profile) async {
    await _repository.saveProfile(profile);
    state = profile;
  }

  Future<void> updateProfile(AppUser profile) async {
    await _repository.updateProfile(profile);
    state = profile;
  }

  Future<void> updateContext(String context) async {
    if (state != null) {
      await _repository.updateContext(state!.id, context);
      
      // Update local state with new context
      state = AppUser(
        id: state!.id,
        email: state!.email,
        name: state!.name,
        avatarEmoji: state!.avatarEmoji,
        userContext: context,
        createdAt: state!.createdAt,
      );
    }
  }
}
