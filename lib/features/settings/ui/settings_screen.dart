import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Widget _buildBiometricSection(BuildContext context, WidgetRef ref) {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final biometricService = ref.watch(biometricAuthServiceProvider);

    return FutureBuilder<bool>(
      future: secureStorage.isBiometricEnabled(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data ?? false;

        return FutureBuilder<String>(
          future: biometricService.getBiometricDisplayName(),
          builder: (context, nameSnapshot) {
            final biometricName = nameSnapshot.data ?? 'Biométrie';

            return Card(
              child: SwitchListTile(
                secondary: const Icon(LucideIcons.fingerprint),
                title: Text(
                  AppLocalizations.of(context).quickLogin,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isEnabled ? '${AppLocalizations.of(context).biometricEnabled} avec $biometricName' : AppLocalizations.of(context).biometricDisabled,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                value: isEnabled,
                onChanged: (value) async {
                  if (value) {
                    // Check if device supports biometric
                    final canUseBiometric = await biometricService.checkBiometricAvailability();
                    
                    if (!canUseBiometric) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context).biometricNotAvailable,
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    // Check if user is authenticated
                    final authService = ref.read(authServiceProvider);
                    if (!authService.isAuthenticated) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Vous devez être connecté pour activer cette fonctionnalité',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                      return;
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Veuillez vous reconnecter pour activer la biométrie',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      );
                    }
                  } else {
                    // Disable biometric
                    await secureStorage.deleteCredentials();
                    await secureStorage.setBiometricEnabled(false);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Connexion rapide désactivée',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.languages,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).appLanguage,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          '🇫🇷 Français',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                          '🇬🇧 English',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settingsTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Text(
            'Langue / Language',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildLanguageSwitcher(context, ref),
          const SizedBox(height: 24),
          
          // Apparence Section
          Text(
            AppLocalizations.of(context).appearance,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeMode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun,
              ),
              title: Text(
                AppLocalizations.of(context).darkMode,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                themeMode == ThemeMode.dark ? AppLocalizations.of(context).biometricEnabled : AppLocalizations.of(context).biometricDisabled,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(LucideIcons.bell),
              title: Text(
                'Activer les notifications',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                notificationsEnabled ? 'Activé' : 'Désactivé',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: notificationsEnabled,
              onChanged: (value) {
                ref.read(notificationsEnabledProvider.notifier).toggle();
              },
            ),
          ),

          const SizedBox(height: 24),

          // Security Section
          Text(
            AppLocalizations.of(context).security,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildBiometricSection(context, ref),

          const SizedBox(height: 24),

          // About Section
          Text(
            AppLocalizations.of(context).about,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.info),
                  title: Text(
                    'Version',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.github),
                  title: Text(
                    'Code source',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(LucideIcons.externalLink, size: 18),
                  onTap: () {
                    // TODO: Open GitHub
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.mail),
                  title: Text(
                    'Support',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(LucideIcons.externalLink, size: 18),
                  onTap: () {
                    // TODO: Open support email
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
