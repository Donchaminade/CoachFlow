import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/shared_conversation_repository.dart';
import '../models/shared_conversation.dart';
import '../data/supabase_sharing_service.dart';
import '../../auth/providers/auth_provider.dart';

final sharedConversationRepositoryProvider = Provider((ref) => SharedConversationRepository());


final sharedConversationsProvider = FutureProvider<List<SharedConversation>>((ref) async {
  // 1. Local (Hive)
  final repository = ref.watch(sharedConversationRepositoryProvider);
  final localConversations = await repository.getAllShared();

  // 2. Remote (Supabase - Direct Share)
  final sharingService = ref.read(supabaseSharingServiceProvider);
  final remoteConversations = await sharingService.getConversationsSharedWithMe();

  // 3. Merge & Sort
  final allShared = [...localConversations];
  for (var remote in remoteConversations) {
    // Avoid duplicates if we accidentally have it locally too
    if (!allShared.any((c) => c.id == remote.id)) {
      allShared.add(remote);
    }
  }
  
  allShared.sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
  return allShared;
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
