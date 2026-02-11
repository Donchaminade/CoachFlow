import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui'; // For ClipRRect and BackdropFilter

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true, // Important for glassmorphism execution
      body: navigationShell,

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
                  _buildNavItem(context, 0, LucideIcons.home, "Accueil"),
                  _buildNavItem(context, 1, LucideIcons.messageCircle, "Messages"),
                  _buildNavItem(context, 2, LucideIcons.users, "Partager"),
                  _buildNavItem(context, 3, LucideIcons.user, "Profil"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    // User requested White icons/text
    final color = isSelected 
        ? Colors.white 
        : Colors.white.withOpacity(0.5);

    return InkWell(
      onTap: () => _onTap(context, index),
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

  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so maintains the state of the navigation stack.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
