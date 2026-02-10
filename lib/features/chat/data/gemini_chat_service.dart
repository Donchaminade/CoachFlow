import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/chat_provider.dart';

class GeminiChatService implements ChatService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiChatService(this.apiKey) {
    _model = GenerativeModel(
      model: 'gemini-pro', // Standard model name
      apiKey: apiKey,
    );
  }

  @override
  Future<String> getResponse(String prompt, String systemPrompt, String userContext) async {
    // Construct the context-aware prompt by combining system prompt and user context
    // Gemini supports system instructions in newer models/SDKs but passing it as context is robust
    final effectiveSystemPrompt = StringBuffer();
    effectiveSystemPrompt.writeln("INSTRUCTION SYSTEME (Tu es ce coach):");
    effectiveSystemPrompt.writeln(systemPrompt);
    
    if (userContext.isNotEmpty) {
      effectiveSystemPrompt.writeln("\nCONTEXTE UTILISATEUR (Prendre en compte pour personnaliser la réponse):");
      effectiveSystemPrompt.writeln(userContext);
    }

    try {
      final chat = _model.startChat(history: [
        Content.text(effectiveSystemPrompt.toString()),
        Content.model([TextPart("Compris. Je suis prêt à coacher en tenant compte de ce contexte.")]),
      ]);
      
      final response = await chat.sendMessage(Content.text(prompt));
      
      return response.text ?? "Désolé, je n'ai pas pu générer de réponse.";
    } catch (e) {
      print("Gemini Error: $e");
      return "Erreur de connexion à Gemini : $e\nVérifiez votre clé API et votre connexion.";
    }
  }
}
