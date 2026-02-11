import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Wait for animations to complete + minimum display time
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check if user has biometric enabled
    final secureStorage = ref.read(secureStorageServiceProvider);
    final hasSavedCredentials = await secureStorage.hasSavedCredentials();
    final biometricEnabled = await secureStorage.isBiometricEnabled();

    if (hasSavedCredentials && biometricEnabled) {
      context.go('/biometric-login');
      return;
    }

    final authService = ref.read(authServiceProvider);
    if (authService.isAuthenticated) {
      context.go('/home');
      return;
    }

    final settingsBox = await Hive.openBox('settings');
    final onboardingSeen = settingsBox.get('onboarding_seen', defaultValue: false);

    if (onboardingSeen) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // 1. Pro Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.4, 1.0],
                colors: isDark 
                  ? [
                      const Color(0xFF121212), 
                      const Color(0xFF1E1E1E), 
                      const Color(0xFF000000)
                    ]
                  : [
                      const Color(0xFFFFFFFF), 
                      const Color(0xFFF8F9FA),
                      const Color(0xFFEEF2F5)
                    ],
              ),
            ),
          ),
          
          // 2. Artistic Blobs (Subtle)
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 1200.ms),
          
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 1500.ms, delay: 200.ms),

          // 3. Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container with soft shadow
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/flow.png',
                    fit: BoxFit.contain,
                  ),
                )
                .animate()
                // Entry animation: Scale + Bounce
                .scale(duration: 800.ms, curve: Curves.easeOutBack, begin: const Offset(0, 0))
                // Then idle breathing animation
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 2000.ms, 
                  begin: const Offset(1.0, 1.0), 
                  end: const Offset(1.05, 1.05),
                  curve: Curves.easeInOutQuad
                ),

                const SizedBox(height: 40),

                // App Name
                Text(
                  'CoachFlow',
                  style: GoogleFonts.outfit( // Using Outfit for modern look if available, else standard
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 12),

                // Tagline with Gradient Text effect simulation (or just subtle color)
                Text(
                  'L\'excellence au quotidien',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),
          
          // 4. Branding / Footer
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor.withOpacity(0.5)
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    color: Colors.grey.withOpacity(0.5)
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 1500.ms),
          ),
        ],
      ),
    );
  }
}
