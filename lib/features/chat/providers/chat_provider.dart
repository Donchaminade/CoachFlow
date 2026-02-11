import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/l10n/locale_provider.dart';
import '../models/message.dart';
import '../data/message_repository.dart';
import '../../coach/models/coach.dart';
import '../../settings/data/user_context_repository.dart';
import '../../settings/providers/user_context_provider.dart';
import '../data/bytez_chat_service.dart';

// Service Interface
abstract class ChatService {
  Future<String> getResponse(
    String prompt,
    String systemPrompt,
    String userContext, {
    Locale? locale,
  });
}

// Mock Implementation (fallback)
class MockChatService implements ChatService {
  @override
  Future<String> getResponse(
    String prompt,
    String systemPrompt,
    String userContext, {
    Locale? locale,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    // Simple logic to show that context is being used
    if (userContext.isNotEmpty) {
      return "Réponse basée sur votre contexte ($userContext) et le profil du coach.\n\n$prompt";
    }
    
    return "Ceci est une réponse simulée basée sur votre message : \"$prompt\". \n\nContexte: $systemPrompt";
  }
}

// Bytez API Key
const String _kBytezKey = "65038c4ed16dbbbc887a67e688f188d8";

final chatServiceProvider = Provider<ChatService>((ref) {
  // Return Bytez Service (using google/gemma-3-1b-it model)
  return BytezChatService(_kBytezKey);
});

final messageRepositoryProvider = Provider((ref) => MessageRepository());

class ChatState {
  final AsyncValue<List<Message>> messages;
  final bool isTyping;

  const ChatState({
    this.messages = const AsyncValue.loading(),
    this.isTyping = false,
  });

  ChatState copyWith({
    AsyncValue<List<Message>>? messages,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, coachId) {
  return ChatNotifier(
    ref.read(messageRepositoryProvider),
    ref.read(chatServiceProvider),
    ref.read(userContextRepositoryProvider),
    coachId,
  );
});

class ChatNotifier extends StateNotifier<ChatState> {
  final MessageRepository _repository;
  final ChatService _chatService;
  final UserContextRepository _userContextRepository;
  final String _coachId;

  ChatNotifier(this._repository, this._chatService, this._userContextRepository, this._coachId) : super(const ChatState()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = state.copyWith(messages: const AsyncValue.loading());
    final msgs = await AsyncValue.guard(() => _repository.getMessagesForCoach(_coachId));
    state = state.copyWith(messages: msgs);
  }

  Future<void> sendMessage(String text, Coach coach, {Locale? locale}) async {
    final currentMessages = state.messages.value ?? [];
    
    // 1. Add User Message
    final userMessage = Message(
      id: const Uuid().v4(),
      coachId: _coachId,
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    await _repository.addMessage(userMessage);
    print("💾 User message saved: ${userMessage.id} for coach: ${_coachId}");
    
    // Optimistic update & set typing to true
    state = state.copyWith(
      messages: AsyncValue.data([...currentMessages, userMessage]),
      isTyping: true,
    );

    // 2. Get AI Response
    try {
      final userContext = await _userContextRepository.getContext();
      final contextString = "Nom: ${userContext.nickname}\nObjectifs: ${userContext.goals}\nValeurs: ${userContext.values}\nContraintes: ${userContext.constraints}";
      
      final responseText = await _chatService.getResponse(
        text,
        coach.systemPrompt,
        contextString,
        locale: locale,
      );
      
      final aiMessage = Message(
        id: const Uuid().v4(),
        coachId: _coachId,
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      await _repository.addMessage(aiMessage);
      print("💾 AI message saved: ${aiMessage.id} for coach: ${_coachId}");
      
      state = state.copyWith(
        messages: AsyncValue.data([...state.messages.value!, aiMessage]),
        isTyping: false,
      );

    } catch (e) {
      print("❌ Error getting AI response: $e");
      state = state.copyWith(isTyping: false);
      // Optionally add an error message to the list or handle context
    }
  }
  Future<void> initializeChat(Coach coach, {Locale? locale}) async {
    // Only initialize if we have loaded messages and there are none
    final currentMessages = state.messages.value;
    if (currentMessages != null && currentMessages.isNotEmpty) {
      return;
    }

    // Double check repo to be sure (in case of race condition or slow state update)
    final existingParams = await _repository.getMessagesForCoach(_coachId);
    if (existingParams.isNotEmpty) {
      // Update state if we missed something
      state = state.copyWith(messages: AsyncValue.data(existingParams));
      return;
    }

    print("🤖 Initializing chat with Smart Welcome for coach: ${coach.name}");
    
    // Set typing indicator
    state = state.copyWith(isTyping: true);

    try {
      final userContext = await _userContextRepository.getContext();
      final contextString = "Nom: ${userContext.nickname}\nObjectifs: ${userContext.goals}";
      
      // Special prompt for introductions
      // We explicitly ask to override the "no intro" rule for this first message
      const introPrompt = "Démarre la conversation maintenant. Présente-toi brièvement en tant que ce coach, rappelle ta mission principale en une phrase, et souhaite la bienvenue à l'utilisateur. Reste chaleureux et motivant.";

      final responseText = await _chatService.getResponse(
        introPrompt, 
        coach.systemPrompt, 
        contextString,
        locale: locale,
      );

      final aiMessage = Message(
        id: const Uuid().v4(),
        coachId: _coachId,
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _repository.addMessage(aiMessage);
      
      // Update state
      final current = state.messages.value ?? [];
      state = state.copyWith(
        messages: AsyncValue.data([...current, aiMessage]),
        isTyping: false,
      );

    } catch (e) {
      print("❌ Error initializing chat: $e");
      state = state.copyWith(isTyping: false);
    }
  }
}

