import 'package:dart_openai/dart_openai.dart';
import 'package:dart_openai/dart_openai.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // We might need dotenv, or just pass key direct for now since user gave it in file
import '../providers/chat_provider.dart';

class OpenAIChatService implements ChatService {
  final String apiKey;

  OpenAIChatService(this.apiKey) {
    OpenAI.apiKey = apiKey;
  }

  @override
  Future<String> getResponse(String prompt, String systemPrompt, String userContext) async {
    // Construct the full system prompt including user context
    String fullSystemPrompt = systemPrompt;
    if (userContext.isNotEmpty) {
      fullSystemPrompt += "\n\nCONTEXTE UTILISATEUR (A PRENDRE EN COMPTE ABSOLUMENT):\n$userContext";
    }

    try {
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(fullSystemPrompt),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final completion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini", // Cost effective and fast
        messages: [
          systemMessage,
          userMessage,
        ],
      );

      return completion.choices.first.message.content?.first.text ?? "Désolé, je n'ai pas pu générer de réponse.";
    } catch (e) {
      print("OpenAI Error: $e");
      return "Erreur de connexion à l'IA : $e";
    }
  }
}
