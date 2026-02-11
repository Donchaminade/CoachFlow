import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Save user credentials securely
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passwordKey, value: password);
      print('✅ Credentials saved securely');
    } catch (e) {
      print('❌ Error saving credentials: $e');
      rethrow;
    }
  }

  /// Get saved credentials
  Future<Map<String, String>?> getCredentials() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);

      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error retrieving credentials: $e');
      return null;
    }
  }

  /// Check if credentials are saved
  Future<bool> hasSavedCredentials() async {
    final credentials = await getCredentials();
    return credentials != null;
  }

  /// Delete saved credentials
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _passwordKey);
      print('✅ Credentials deleted');
    } catch (e) {
      print('❌ Error deleting credentials: $e');
      rethrow;
    }
  }

  /// Set biometric enabled preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      print('❌ Error setting biometric preference: $e');
    }
  }

  /// Get biometric enabled preference
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      print('❌ Error getting biometric preference: $e');
      return false;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      print('✅ All secure storage cleared');
    } catch (e) {
      print('❌ Error clearing storage: $e');
    }
  }
}
