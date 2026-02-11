import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../settings/providers/user_context_provider.dart';
import '../../settings/models/user_context.dart';

class UserContextScreen extends ConsumerStatefulWidget {
  const UserContextScreen({super.key});

  @override
  ConsumerState<UserContextScreen> createState() => _UserContextScreenState();
}

class _UserContextScreenState extends ConsumerState<UserContextScreen> {
  final _nicknameController = TextEditingController();
  final _goalsController = TextEditingController();
  final _valuesController = TextEditingController();
  final _constraintsController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _goalsController.dispose();
    _valuesController.dispose();
    _constraintsController.dispose();
    super.dispose();
  }

  void _saveContext() {
    final newContext = UserContext(
      nickname: _nicknameController.text.trim(),
      goals: _goalsController.text.trim(),
      values: _valuesController.text.trim(),
      constraints: _constraintsController.text.trim(),
    );

    ref.read(userContextProvider.notifier).updateContext(newContext);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contexte sauvegardé !')),
    );
     context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(userContextProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Initialize controllers with data once loaded
    contextAsync.whenData((userContext) {
      if (!_initialized) {
        _nicknameController.text = userContext.nickname;
        _goalsController.text = userContext.goals;
        _valuesController.text = userContext.values;
        _constraintsController.text = userContext.constraints;
        _initialized = true;
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Mon Contexte',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black, // Force black
        foregroundColor: Colors.white, // Force white icons
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveContext,
            color: Colors.white,
          ),
        ],
      ),
      body: contextAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                context,
                'Pourquoi c\'est important ?',
                'Ces informations sont partagées avec TOUS vos coachs. Plus vous êtes précis, plus leurs conseils seront pertinents.',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nicknameController,
                label: 'Comment je m\'appelle',
                hint: 'Votre prénom ou surnom',
                icon: Icons.person_outline,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _goalsController,
                label: 'Mes Objectifs Actuels',
                hint: 'Ex: Lancer mon entreprise, courir un marathon...',
                icon: Icons.flag_outlined,
                maxLines: 3,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _valuesController,
                label: 'Mes Valeurs / Principes',
                hint: 'Ex: Honnêteté, Famille avant tout, Minimalisme...',
                icon: Icons.diamond_outlined,
                maxLines: 3,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _constraintsController,
                label: 'Mes Contraintes / Contexte',
                hint: 'Ex: J\'ai 2 enfants, je travaille de nuit, budget limité...',
                icon: Icons.warning_amber_outlined,
                maxLines: 3,
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveContext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    'Sauvegarder mon Profil',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required ThemeData theme,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.cardColor,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
