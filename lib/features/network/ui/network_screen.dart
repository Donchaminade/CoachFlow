import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/network_provider.dart';
import '../../auth/models/auth_user.dart';

class NetworkScreen extends ConsumerStatefulWidget {
  const NetworkScreen({super.key});

  @override
  ConsumerState<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends ConsumerState<NetworkScreen> {
  bool _isSearchVisible = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).state = '';
      }
    });
  }

  void _hideSearch() {
    setState(() {
      _isSearchVisible = false;
      _searchController.clear();
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Mon Réseau',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? LucideIcons.x : LucideIcons.search),
            tooltip: _isSearchVisible ? 'Fermer la recherche' : 'Rechercher',
            onPressed: _toggleSearch,
          ),
          if (!_isSearchVisible)
            IconButton(
              icon: const Icon(LucideIcons.home),
              tooltip: 'Accueil',
              onPressed: () => context.go('/home'),
            ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Search Bar (Animated)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un contact...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: _hideSearch,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
            crossFadeState: _isSearchVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: 300.ms,
          ),

          // 2. Content
          Expanded(
            child: searchQuery.length >= 3
                ? _buildSearchResults(ref, searchResultsAsync)
                : _buildContactsList(ref, contactsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(WidgetRef ref, AsyncValue contactsAsync) {
    return contactsAsync.when(
      data: (contacts) {
        if (contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.users, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Votre réseau est vide',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recherchez des utilisateurs pour les ajouter',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(contact.avatarEmoji),
                ),
                title: Text(
                  contact.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  contact.email,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(LucideIcons.userMinus, color: Colors.red),
                  onPressed: () async {
                     // Confirm dialog
                     final confirm = await showDialog<bool>(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Supprimer ?'),
                         content: Text('Voulez-vous retirer ${contact.name} de votre réseau ?'),
                         actions: [
                           TextButton(onPressed: ()=>Navigator.pop(context, false), child: const Text('Annuler')),
                           TextButton(onPressed: ()=>Navigator.pop(context, true), child: const Text('Supprimer')),
                         ],
                       ),
                     );
                     
                     if (confirm == true) {
                       await ref.read(networkRepositoryProvider).removeContact(contact.contactId);
                       // Force refresh
                       ref.invalidate(contactsProvider);
                     }
                  },
                ),
              ),
            ).animate().fadeIn(delay: (50 * index).ms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
    );
  }

  Widget _buildSearchResults(WidgetRef ref, AsyncValue<List<AppUser>> resultsAsync) {
    return resultsAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(child: Text('Aucun utilisateur trouvé', style: GoogleFonts.poppins()));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.avatarEmoji ?? '👤'),
                ),
                title: Text(user.name ?? 'Utilisateur', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(user.email, style: GoogleFonts.poppins(fontSize: 12)),
                trailing: ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(networkRepositoryProvider).addContact(user.id);
                    // Clear search
                    ref.read(searchQueryProvider.notifier).state = '';
                    _searchController.clear(); 
                    setState(() => _isSearchVisible = false);
                    // Refresh contacts
                    ref.invalidate(contactsProvider);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${user.name} ajouté !')),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.userPlus, size: 16),
                  label: const Text('Suivre'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur recherche: $err')),
    );
  }
}
