import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        reason: 'Bob retour ! Authentifiez-vous pour continuer.',
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
          _errorMessage = 'Authentification annulée ou échouée';
        });
      }
    } catch (e) {
      print('❌ Error during biometric auth: $e');
      setState(() {
        _errorMessage = 'Erreur lors de l\'authentification';
      });
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF5F5F7)],
              ),
            ),
          ),
          
          // Background accents (Circles)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Theme.of(context).cardColor.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Wrap content
                      children: [
                        // Logo / Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: const Text('🧠', style: TextStyle(fontSize: 48)),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'CoachFlow',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Bon retour !', // Restored
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 40),
                        
                        // Biometric Area
                        FutureBuilder<String>(
                          future: ref.read(biometricAuthServiceProvider).getBiometricDisplayName(),
                          builder: (context, snapshot) {
                            final biometricName = snapshot.data ?? 'Biométrie';
                            
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: _isAuthenticating ? null : _authenticateWithBiometric,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(_isAuthenticating ? 0.2 : 0.1),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(_isAuthenticating ? 1.0 : 0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (_isAuthenticating)
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).colorScheme.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        Icon(
                                          _getBiometricIcon(snapshot.data),
                                          size: 40,
                                          color: Theme.of(context).colorScheme.primary,
                                        ).animate(
                                          onPlay: (c) => _isAuthenticating ? c.repeat(reverse: true) : c.stop(),
                                        ).scale(begin: const Offset(1, 1), end: const Offset(0.9, 0.9), duration: 1000.ms),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _isAuthenticating ? 'Vérification...' : 'Se connecter avec $biometricName',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),

                        // Error Message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fadeIn(),
                        
                        const Divider(),
                        
                        // Alternative Button
                        TextButton(
                          onPressed: () => context.go('/auth'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text(
                            'Utiliser un mot de passe',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms).fadeIn(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon(String? biometricName) {
    if (biometricName == null) return LucideIcons.fingerprint;
    
    final lowerName = biometricName.toLowerCase();
    if (lowerName.contains('face') || lowerName.contains('visage')) {
      return LucideIcons.scanFace;
    } else if (lowerName.contains('iris')) {
      return LucideIcons.eye;
    } else {
      return LucideIcons.fingerprint;
    }
  }
}
