import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/coach/ui/create_coach_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/settings/ui/user_context_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/profile/ui/profile_setup_screen.dart';
import '../../features/sharing/ui/shared_conversations_screen.dart';
import '../../features/sharing/ui/view_shared_conversation_screen.dart';
import '../../features/chat/ui/chat_list_screen.dart';
import '../../features/onboarding/ui/onboarding_screen.dart';
import '../../features/auth/ui/auth_screen.dart';
import '../../features/auth/ui/biometric_login_screen.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/home/ui/main_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
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
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/biometric-login',
        name: 'biometric-login',
        builder: (context, state) => const BiometricLoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      
      // Main Application Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'create-coach',
                    name: 'create-coach',
                     parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav
                    builder: (context, state) => const CreateCoachScreen(),
                  ),
                ],
              ),
            ],
          ),
          
          // Branch 1: Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                name: 'messages',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          
          // Branch 2: Shared
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shared',
                name: 'shared-conversations',
                builder: (context, state) => const SharedConversationsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'view-shared-conversation',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ViewSharedConversationScreen(shareId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const UserContextScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    parentNavigatorKey: _rootNavigatorKey, // Hide bottom nav for settings? User didn't specify, but standard practice.
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Global Route: Chat (Hides bottom nav)
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatScreen(coachId: id);
        },
      ),
    ],
  );
});
