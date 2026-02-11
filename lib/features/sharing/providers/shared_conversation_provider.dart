import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shared_conversation_repository.dart';
import '../models/shared_conversation.dart';
import '../data/supabase_sharing_service.dart';
import '../../auth/providers/auth_provider.dart';

final sharedConversationRepositoryProvider = Provider((ref) => SharedConversationRepository());

final sharedConversationsProvider = FutureProvider<List<SharedConversation>>((ref) async {
  final repository = ref.watch(sharedConversationRepositoryProvider);
  return await repository.getAllShared();
});

final sharedConversationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(sharedConversationRepositoryProvider);
  return await repository.getCount();
});

// Supabase sharing service provider
final supabaseSharingServiceProvider = Provider<SupabaseSharingService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseSharingService(supabase);
});
