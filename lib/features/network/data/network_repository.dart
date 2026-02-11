import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contact.dart';
import '../../auth/models/auth_user.dart';



class NetworkRepository {
  final SupabaseClient _supabase;

  NetworkRepository(this._supabase);

  // 1. Search Users (by email or name)
  Future<List<AppUser>> searchUsers(String query) async {
    if (query.length < 3) return []; // Minimum 3 chars

    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('email.ilike.%$query%,name.ilike.%$query%')
          .limit(20);

      // Filter out current user
      final currentUserId = _supabase.auth.currentUser?.id;
      final users = (response as List)
          .map((json) => AppUser.fromJson(json))
          .where((user) => user.id != currentUserId)
          .toList();

      return users;
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // 2. Get My Contacts
  Stream<List<Contact>> getContacts() {
    return _supabase
        .from('contacts')
        .stream(primaryKey: ['id'])
        .eq('user_id', _supabase.auth.currentUser!.id)
        .asyncMap((data) async {
          // Enhancing contact data with user details
          // Note: In a real app we would use a join query, but strict RLS might make it tricky with stream
          // For now, simpler to fetch the contact details
          
          List<Contact> contacts = [];
          
          for (var item in data) {
             final contactUserId = item['contact_id'];
             // Fetch user details
             final userResponse = await _supabase
                 .from('users')
                 .select()
                 .eq('id', contactUserId)
                 .maybeSingle();
                 
             if (userResponse != null) {
               contacts.add(Contact(
                 id: item['id'],
                 contactId: contactUserId,
                 name: userResponse['name'] ?? 'Unknown',
                 email: userResponse['email'] ?? '',
                 avatarEmoji: userResponse['avatar_emoji'] ?? '👤',
                 createdAt: DateTime.parse(item['created_at']),
               ));
             }
          }
          return contacts;
        });
  }

  // 3. Add Contact
  Future<void> addContact(String contactId) async {
    final userId = _supabase.auth.currentUser!.id;
    try {
      await _supabase.from('contacts').insert({
        'user_id': userId,
        'contact_id': contactId,
      });
    } catch (e) {
      // Handle unique constraint violation (already added)
      if (e.toString().contains('duplicate key')) {
        print('⚠️ Contact already exists');
        return;
      }
      rethrow;
    }
  }

  // 4. Remove Contact
  Future<void> removeContact(String contactId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('contacts')
        .delete()
        .eq('user_id', userId)
        .eq('contact_id', contactId);
  }
}
