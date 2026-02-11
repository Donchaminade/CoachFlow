import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available
  Future<bool> checkBiometricAvailability() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getBiometricTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('❌ Error getting biometric types: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      final canAuthenticate = await checkBiometricAvailability();
      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permet PIN/Pattern comme fallback
        ),
      );
    } on PlatformException catch (e) {
      print('❌ Error during authentication: $e');
      return false;
    }
  }

  /// Check if device has biometric hardware
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('❌ Error checking device support: $e');
      return false;
    }
  }

  /// Get biometric type name for display
  Future<String> getBiometricDisplayName() async {
    final types = await getBiometricTypes();
    
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (types.contains(BiometricType.iris)) {
      return 'Reconnaissance iris';
    } else if (types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
      return 'Biométrie';
    } else {
      return 'PIN/Schéma';
    }
  }
}
