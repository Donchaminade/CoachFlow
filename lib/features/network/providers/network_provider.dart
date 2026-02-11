import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact.dart';
import '../data/network_repository.dart';
import '../../auth/models/auth_user.dart';

// Repository Provider
final networkRepositoryProvider = Provider<NetworkRepository>((ref) {
  return NetworkRepository(Supabase.instance.client);
});

// My Contacts Stream
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final repository = ref.watch(networkRepositoryProvider);
  return repository.getContacts();
});

// Search Query State
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search Results Future
final searchResultsProvider = FutureProvider.autoDispose<List<AppUser>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 3) return [];

  final repository = ref.watch(networkRepositoryProvider);
  return repository.searchUsers(query);
});
