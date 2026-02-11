import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';

class BiometricLoginScreen extends ConsumerStatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  ConsumerState<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends ConsumerState<BiometricLoginScreen> {
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometric();
    });
  }

  Future<void> _authenticateWithBiometric() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final biometricService = ref.read(biometricAuthServiceProvider);
      final secureStorage = ref.read(secureStorageServiceProvider);
      
      // Authenticate
      final authenticated = await biometricService.authenticate(
        reason: 'Authentifiez-vous pour accéder à CoachFlow',
      );

      if (authenticated) {
        // Get saved credentials
        final credentials = await secureStorage.getCredentials();
        
        if (credentials != null) {
          // Sign in with saved credentials
          final authService = ref.read(authServiceProvider);
          final user = await authService.signIn(
            email: credentials['email']!,
            password: credentials['password']!,
          );

          if (user != null && mounted) {
            context.go('/home');
          } else {
            setState(() {
              _errorMessage = 'Erreur de connexion';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Identifiants non trouvés';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Authentification échouée';
        });
      }
    } catch (e) {
      print('❌ Error during biometric auth: $e');
      setState(() {
        _errorMessage = 'Erreur lors de l\'authentification';
      });
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              Text(
                '🧠',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              
              Text(
                'CoachFlow',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'Bon retour !',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Biometric button
              FutureBuilder<String>(
                future: ref.read(biometricAuthServiceProvider).getBiometricDisplayName(),
                builder: (context, snapshot) {
                  final biometricName = snapshot.data ?? 'Biométrie';
                  
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: _isAuthenticating ? null : _authenticateWithBiometric,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: _isAuthenticating
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  _getBiometricIcon(snapshot.data),
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Se connecter avec $biometricName',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.alertCircle, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Alternative login
              TextButton.icon(
                onPressed: () => context.pushNamed('auth'),
                icon: const Icon(LucideIcons.logIn),
                label: Text(
                  'Se connecter avec un autre compte',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(String? biometricName) {
    if (biometricName == null) return LucideIcons.fingerprint;
    
    if (biometricName.contains('Face')) {
      return LucideIcons.scanFace;
    } else if (biometricName.contains('Empreinte')) {
      return LucideIcons.fingerprint;
    } else if (biometricName.contains('iris')) {
      return LucideIcons.eye;
    } else {
      return LucideIcons.lock;
    }
  }
}
