import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Artificial delay for the splash animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final settingsBox = await Hive.openBox('settings');
    final onboardingSeen = settingsBox.get('onboarding_seen', defaultValue: false);

    if (onboardingSeen) {
      context.go('/home'); // Go to MainScreen (which we will create next, aliased as /home for now)
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon (using Lucide or Standard for now until asset is ready)
            Icon(
              Icons.psychology, // Placeholder for brain/coach icon
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.1, duration: 1000.ms, curve: Curves.easeInOut) // Breathing effect
            .then()
            .shimmer(duration: 1500.ms, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),

            const SizedBox(height: 16),
            
            Text(
              "CoachFlow",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),
          ],
        ),
      ),
    );
  }
}
