import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/coach.dart';
import '../providers/coach_provider.dart';

class CreateCoachScreen extends ConsumerStatefulWidget {
  const CreateCoachScreen({super.key});

  @override
  ConsumerState<CreateCoachScreen> createState() => _CreateCoachScreenState();
}

class _CreateCoachScreenState extends ConsumerState<CreateCoachScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptController = TextEditingController();
  String _selectedAvatar = '🤖';

  final List<String> _avatars = [
    '🤖', '🧠', '💼', '💪', '🧘', '🎓', '🎨', '🚀', '🍏', '👨‍🍳', '🧪', 
    '🦁', '🦉', '👑', '🔥', '💡', '🏆', '🎯', '📚', '🎤', '🎬'
  ];

  final Map<String, String> _promptTemplates = {
    'Motivant': 'Tu es un coach ultra-motivant. Tu utilises des phrases courtes, dynamiques et plein d\'emojis. Ton but est de pousser l\'utilisateur à l\'action immédiate.',
    'Strict': 'Tu es un instructeur strict et discipliné. Tu ne tolères pas les excuses. Tu es direct, précis et exigeant. La discipline est la clé du succès.',
    'Socratique': 'Tu es un philosophe sage. Tu ne donnes pas les réponses directement, mais tu poses des questions profondes ("Maïeutique") pour aider l\'utilisateur à trouver ses propres solutions.',
    'Empathique': 'Tu es un confident bienveillant. Tu écoutes avec attention, tu valides les émotions et tu offres un soutien inconditionnel. La douceur et la compréhension sont tes outils.',
    'Analytique': 'Tu es un expert data-driven. Tu analyses les faits, tu demandes des précisions et tu proposes des plans d\'action logiques, structurés et basés sur des preuves.',
    'Cynique': 'Tu es un coach cynique. Tu ne tolères pas les excuses. Tu es direct, précis et exigeant. La discipline est la clé du succès.',
    
  };

  @override
  void initState() {
    super.initState();
    // Listen to changes to rebuild preview
    _nameController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveCoach() async {
    if (_formKey.currentState!.validate()) {
      final coach = Coach(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        systemPrompt: _promptController.text.trim(),
        avatarIcon: _selectedAvatar,
      );

      await ref.read(coachControllerProvider.notifier).addCoach(coach);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coach "${coach.name}" créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _applyTemplate(String template) {
    _promptController.text = template;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modèle appliqué !'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Nouveau Coach',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black, // Force black background
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white), // Force white icon
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PREVIEW SECTION
              Center(
                child: Column(
                  children: [
                    Text(
                      'APERÇU',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: isDark ? Colors.white24 : Colors.transparent, width: 1), // Unified border logic
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _selectedAvatar,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nameController.text.isEmpty ? 'Nom du Coach' : _nameController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _descriptionController.text.isEmpty ? 'Une courte description apparaîtra ici...' : _descriptionController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 32),

              // FORM SECTION
              Text(
                'Identité',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Avatar Selector
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = avatar == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                          ),
                          boxShadow: isSelected 
                              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] 
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatar,
                          style: TextStyle(fontSize: 28, color: isSelected ? (isDark ? Colors.black : Colors.white) : null),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Name Input
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(LucideIcons.user),
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
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),
              
              const SizedBox(height: 16),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(LucideIcons.info),
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
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),

              const SizedBox(height: 32),

              Text(
                'Comportement (Prompt)',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Template Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _promptTemplates.entries.map((entry) {
                  return ActionChip(
                    label: Text(entry.key, style: GoogleFonts.poppins(fontSize: 12)),
                    avatar: const Icon(LucideIcons.sparkles, size: 14),
                    onPressed: () => _applyTemplate(entry.value),
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),

              // Prompt Input
              TextFormField(
                controller: _promptController,
                style: GoogleFonts.poppins(),
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Instructions Système',
                  labelStyle: GoogleFonts.poppins(),
                  alignLabelWithHint: true,
                  hintText: 'Définissez ici la personnalité et les règles de votre coach...',
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
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),

              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveCoach,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white, // Logic requested by user
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  icon: const Icon(LucideIcons.checkCircle),
                  label: Text(
                    'Créer le Coach',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }
}
