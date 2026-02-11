import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../../features/profile/providers/user_profile_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        userProfile?.avatarEmoji ?? '👋',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (userProfile != null) ...[
                    Text(
                      userProfile!.name ?? AppLocalizations.of(context).user,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                    if (userProfile!.email != null)
                      Text(
                        userProfile!.email!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black54
                              : Colors.white.withOpacity(0.8),
                        ),
                      ),
                  ] else ...[
                    Text(
                      'Mode Invité',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        context.push('/auth');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Text(
                          'Se connecter / S\'inscrire',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Language Switcher
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLanguageSwitcher(context, ref),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.settings,
                  title: AppLocalizations.of(context).settings,
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('settings');
                  },
                ),
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.history,
                  title: AppLocalizations.of(context).history,
                  subtitle: AppLocalizations.of(context).allConversations,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/messages');
                  },
                ),
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.users,
                  title: 'Mon Réseau', // TODO: Add to l10n
                  subtitle: 'Gérer vos contacts',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/network');
                  },
                ),
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.share2,
                  title: AppLocalizations.of(context).sharedConversations,
                  subtitle: AppLocalizations.of(context).receivedFromOthers,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/shared');
                  },
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.info,
                  title: AppLocalizations.of(context).about,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  ref,
                  icon: LucideIcons.helpCircle,
                  title: AppLocalizations.of(context).helpSupport,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (ref.watch(authStateProvider).value != null) ...[
                  const Divider(height: 32),
                  _buildMenuItem(
                    context,
                    ref,
                    icon: LucideIcons.logOut,
                    title: 'Se déconnecter', // TODO: Add to l10n
                    onTap: () async {
                      Navigator.pop(context);
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Déconnecter', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) {
                          context.go('/auth');
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context).appVersion,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('fr')),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: locale.languageCode == 'fr'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: locale.languageCode == 'fr'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '🇫🇷 FR',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: locale.languageCode == 'fr'
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: locale.languageCode == 'fr'
                        ? Colors.black
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: locale.languageCode == 'en'
                      ? Colors.black
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: locale.languageCode == 'en'
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  '🇬🇧 EN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: locale.languageCode == 'en'
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: locale.languageCode == 'en'
                        ? Colors.white
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CoachFlow',
      applicationVersion: '1.0.0',
      applicationIcon: const Text('🧠', style: TextStyle(fontSize: 48)),
      children: [
        Text(
          AppLocalizations.of(context).appDescription,
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }
}
