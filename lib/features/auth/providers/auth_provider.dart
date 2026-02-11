import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_user.dart' as app;
import '../services/biometric_auth_service.dart';
import '../services/secure_storage_service.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((data) => data.session?.user);
});

// Current auth user provider
final currentAuthUserProvider = FutureProvider<app.AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      
      // Fetch user details from users table
      final supabase = ref.watch(supabaseClientProvider);
      final response = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) return null;
      
      return app.AppUser.fromJson(response);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Sign up with email and password
  Future<app.AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    String avatarEmoji = '🧑',
  }) async {
    try {
      // Sign up with Supabase Auth and metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'avatar_emoji': avatarEmoji,
        },
      );

      if (response.user == null) return null;

      // User profile is automatically created by trigger

      return app.AppUser(
        id: response.user!.id,
        email: email,
        name: name,
        avatarEmoji: avatarEmoji,
        createdAt: DateTime.now(), // Approximate
      );
    } catch (e) {
      print('❌ Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<app.AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      // Fetch user profile
      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return app.AppUser.fromJson(userProfile);
    } catch (e) {
      print('❌ Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('❌ Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
}

// Biometric auth service provider
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

// Secure storage service provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Biometric enabled state provider
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return await storage.isBiometricEnabled();
});
