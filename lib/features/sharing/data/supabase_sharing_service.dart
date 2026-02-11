import 'package:supabase_flutter/supabase_flutter.dart';
import '../../chat/models/message.dart';
import '../../coach/models/coach.dart';
import '../models/shared_conversation.dart';

class SupabaseSharingService {
  final SupabaseClient _supabase;

  SupabaseSharingService(this._supabase);

  /// Upload a conversation to Supabase
  Future<String> uploadConversation({
    required String shareId,
    required String coachName,
    required String coachAvatar,
    required List<Message> messages,
    String? title,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert messages to JSON
      final messagesJson = messages.map((msg) {
        return {
          'id': msg.id,
          'text': msg.text,
          'isUser': msg.isUser,
          'timestamp': msg.timestamp.toIso8601String(),
        };
      }).toList();

      // Upload to Supabase
      await _supabase.from('shared_conversations').insert({
        'id': shareId,
        'user_id': userId,
        'coach_name': coachName,
        'coach_avatar': coachAvatar,
        'messages': messagesJson,
        'title': title,
      });

      print('✅ Conversation uploaded: $shareId');
      return shareId;
    } catch (e) {
      print('❌ Error uploading conversation: $e');
      rethrow;
    }
  }

  /// Download a conversation from Supabase by share code
  Future<SharedConversation?> downloadConversation(String shareId) async {
    try {
      final response = await _supabase
          .from('shared_conversations')
          .select()
          .eq('id', shareId)
          .maybeSingle();

      if (response == null) {
        print('❌ Conversation not found: $shareId');
        return null;
      }

      // Parse messages from JSON
      final messagesJson = response['messages'] as List<dynamic>;
      final messages = messagesJson.map((msgJson) {
        return Message(
          id: msgJson['id'] as String,
          text: msgJson['text'] as String,
          isUser: msgJson['isUser'] as bool,
          timestamp: DateTime.parse(msgJson['timestamp'] as String),
          coachId: '', // Will be set later
        );
      }).toList();

      // Create a Coach object from the stored data
      final coach = Coach(
        id: '', // Temporary ID since we don't store it
        name: response['coach_name'] as String,
        description: 'Conversation partagée',
        systemPrompt: '',
        avatarIcon: response['coach_avatar'] as String,
      );

      final sharedConv = SharedConversation(
        id: response['id'] as String,
        sharedBy: 'Utilisateur', // We don't store this yet
        coach: coach,
        messages: messages,
        title: response['title'] as String?,
        sharedAt: DateTime.parse(response['shared_at'] as String),
      );

      print('✅ Conversation downloaded: $shareId');
      return sharedConv;
    } catch (e) {
      print('❌ Error downloading conversation: $e');
      rethrow;
    }
  }

  /// Search user by email
  Future<Map<String, dynamic>?> searchUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error searching user: $e');
      return null;
    }
  }

  /// Get all shared conversations by current user
  Future<List<SharedConversation>> getMySharedConversations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('shared_conversations')
          .select()
          .eq('user_id', userId)
          .order('shared_at', ascending: false);

      final List<SharedConversation> conversations = (response as List).map((data) {
        final messagesJson = data['messages'] as List<dynamic>;
        final messages = messagesJson.map((msgJson) {
          return Message(
            id: msgJson['id'] as String,
            text: msgJson['text'] as String,
            isUser: msgJson['isUser'] as bool,
            timestamp: DateTime.parse(msgJson['timestamp'] as String),
            coachId: '',
          );
        }).toList();

        final coach = Coach(
          id: '',
          name: data['coach_name'] as String,
          description: 'Conversation partagée',
          systemPrompt: '',
          avatarIcon: data['coach_avatar'] as String,
        );

        return SharedConversation(
          id: data['id'] as String,
          sharedBy: 'Utilisateur',
          coach: coach,

          messages: messages,
          title: data['title'] as String?,
          sharedAt: DateTime.parse(data['shared_at'] as String),
        );
      }).toList();

      return conversations;
    } catch (e) {
      print('❌ Error fetching shared conversations: $e');
      return [];
    }
  }
}
