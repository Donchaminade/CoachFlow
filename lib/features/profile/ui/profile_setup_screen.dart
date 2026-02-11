import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contextController = TextEditingController();

  int _currentPage = 0;
  String _selectedEmoji = '🧑';

  final List<String> _emojiOptions = [
    '🧑', '👨', '👩', '🧔', '👱', '🧓',
    '😀', '😊', '🤓', '😎', '🥳', '🤩',
    '🦁', '🐯', '🦊', '🐼', '🐨', '🦉',
    '🚀', '⚡', '🔥', '💎', '🌟', '✨',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createProfile();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _createProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un nom', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authUser = ref.read(currentAuthUserProvider).value;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: Utilisateur non connecté', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final profile = AppUser(
      id: authUser.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? authUser.email : _emailController.text.trim(),
      avatarEmoji: _selectedEmoji,
      createdAt: authUser.createdAt ?? DateTime.now(),
      userContext: _contextController.text.trim().isEmpty ? null : _contextController.text.trim(),
    );

    await ref.read(userProfileProvider.notifier).updateProfile(profile);

    if (mounted) {
      context.go('/'); // Navigate to home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildNamePage(),
                  _buildAvatarPage(),
                  _buildContextPage(),
                ],
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? 'Créer mon profil' : 'Suivant',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue sur\nCoachFlow 👋',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Commençons par créer votre profil',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Votre nom',
              hintText: 'Ex: Marie Dupont',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.poppins(),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email (optionnel)',
              hintText: 'votreemail@exemple.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.poppins(),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre avatar',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un emoji qui vous représente',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _emojiOptions.length,
              itemBuilder: (context, index) {
                final emoji = _emojiOptions[index];
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parlez-nous de vous',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vos objectifs, préférences, contexte... (optionnel)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _contextController,
            decoration: InputDecoration(
              labelText: 'Votre contexte',
              hintText: 'Ex: Je suis entrepreneur et je souhaite améliorer ma productivité...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            style: GoogleFonts.poppins(),
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Text(
            'Ce contexte aidera vos coachs à mieux vous comprendre',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
