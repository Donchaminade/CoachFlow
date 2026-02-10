import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui'; // For ClipRRect and BackdropFilter

import 'home_screen.dart';
import '../../chat/ui/chat_list_screen.dart'; 
import '../../settings/ui/user_context_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatListScreen(),
    const Center(child: Text("Historique - Bientôt disponible")), // Placeholder for History
    const UserContextScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBody: true, // Important for glassmorphism execution
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.black.withOpacity(0.85), // Force Black
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, LucideIcons.home, "Accueil"),
                  _buildNavItem(1, LucideIcons.messageCircle, "Messages"),
                  _buildNavItem(2, LucideIcons.history, "Historique"), // New Item
                  _buildNavItem(3, LucideIcons.user, "Profil"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    // User requested White icons/text
    final color = isSelected 
        ? Colors.white 
        : Colors.white.withOpacity(0.5);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28), // Increased size
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12, // Increased size
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
