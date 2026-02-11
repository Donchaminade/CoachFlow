import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  final List<String> _avatars = ['🤖', '🧠', '💼', '💪', '🧘', '🎓', '🎨', '🚀', '🍏','👨‍🍳', '🧪'];

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Coach'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avatar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = avatar == _selectedAvatar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).cardTheme.color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du Coach',
                  hintText: 'Ex: Coach Productivité',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description courte',
                  hintText: 'Ex: Expert en gestion du temps',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Prompt Système (Instructions)',
                  hintText: 'Ex: Tu es un expert en productivité. Tu dois...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCoach,
                  child: const Text('Créer le Coach'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
