import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/coach/ui/create_coach_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/settings/ui/user_context_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';

import '../../features/splash/ui/splash_screen.dart';
import '../../features/home/ui/main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainScreen(), // Main with BottomNav
        routes: [
          GoRoute(
            path: 'create-coach',
            name: 'create-coach',
            builder: (context, state) => const CreateCoachScreen(),
          ),
          GoRoute(
            path: 'user-context',
            name: 'user-context',
            builder: (context, state) => const UserContextScreen(),
          ),
          GoRoute(
            path: 'chat/:id',
            name: 'chat',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ChatScreen(coachId: id);
            },
          ),
        ],
      ),
    ],
  );
});
