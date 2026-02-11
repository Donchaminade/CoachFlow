import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class BiometricSetupDialog extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const BiometricSetupDialog({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<BiometricSetupDialog> createState() => _BiometricSetupDialogState();
}

class _BiometricSetupDialogState extends ConsumerState<BiometricSetupDialog> {
  String _biometricName = 'Biométrie';

  @override
  void initState() {
    super.initState();
    _loadBiometricName();
  }

  Future<void> _loadBiometricName() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final name = await biometricService.getBiometricDisplayName();
    setState(() => _biometricName = name);
  }

  Future<void> _enableBiometric() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    
    // Save credentials
    await secureStorage.saveCredentials(
      email: widget.email,
      password: widget.password,
    );
    
    // Enable biometric
    await secureStorage.setBiometricEnabled(true);
    
    if (mounted) {
      Navigator.pop(context, true);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Connexion rapide activée !',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            LucideIcons.fingerprint,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Activer la connexion rapide ?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Utilisez $_biometricName pour vous connecter rapidement à la prochaine ouverture de l\'application.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.shield,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vos identifiants sont stockés de manière sécurisée sur votre appareil',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Plus tard',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _enableBiometric,
          icon: const Icon(LucideIcons.check),
          label: Text(
            'Activer',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
