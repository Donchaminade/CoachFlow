import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/models/auth_user.dart';

class UserProfileRepository {
  final SupabaseClient _supabase;

  UserProfileRepository(this._supabase);

  Future<AppUser?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return AppUser.fromJson(response);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  Future<void> saveProfile(AppUser profile) async {
    try {
      // We use upsert to handle both insert and update
      await _supabase.from('users').upsert(profile.toJson());
      print("✅ Profile saved: ${profile.name}");
    } catch (e) {
      print('❌ Error saving profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(AppUser profile) async {
    await saveProfile(profile);
  }

  Future<void> updateContext(String userId, String context) async {
    try {
      await _supabase.from('users').update({
        'user_context': context,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      print("✅ Context updated");
    } catch (e) {
      print('❌ Error updating context: $e');
      rethrow;
    }
  }
}
