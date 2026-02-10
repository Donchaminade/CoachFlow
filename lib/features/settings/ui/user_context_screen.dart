import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Mon Contexte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveContext,
          ),
        ],
      ),
      body: contextAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                context,
                'Pourquoi c\'est important ?',
                'Ces informations sont partagées avec TOUS vos coachs. Plus vous êtes précis, plus leurs conseils seront pertinents.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Comment je m\'appelle',
                  hintText: 'Votre prénom ou surnom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalsController,
                decoration: const InputDecoration(
                  labelText: 'Mes Objectifs Actuels',
                  hintText: 'Ex: Lancer mon entreprise, courir un marathon...',
                  prefixIcon: Icon(Icons.flag_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valuesController,
                decoration: const InputDecoration(
                  labelText: 'Mes Valeurs / Principes',
                  hintText: 'Ex: Honnêteté, Famille avant tout, Minimalisme...',
                  prefixIcon: Icon(Icons.diamond_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _constraintsController,
                decoration: const InputDecoration(
                  labelText: 'Mes Contraintes / Contexte',
                  hintText: 'Ex: J\'ai 2 enfants, je travaille de nuit, budget limité...',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContext,
                  child: const Text('Sauvegarder mon Profil'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
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
