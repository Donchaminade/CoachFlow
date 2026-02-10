import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/chat_provider.dart';

class BytezChatService implements ChatService {
  final String apiKey;
  final String baseUrl = 'https://api.bytez.com/v1';
  final String model = 'google/gemma-3-1b-it';

  BytezChatService(this.apiKey);

  @override
  Future<String> getResponse(String prompt, String systemPrompt, String userContext) async {
    try {
      // Construct messages array with system context
      final messages = <Map<String, String>>[];
      
      // Add system instruction as first message
      final systemMessage = StringBuffer();
      systemMessage.writeln("RÈGLE ABSOLUE - LANGUE:");
      systemMessage.writeln("TU DOIS TOUJOURS répondre dans la MÊME LANGUE que l'utilisateur.");
      systemMessage.writeln("Si l'utilisateur écrit en FRANÇAIS, tu DOIS répondre en FRANÇAIS.");
      systemMessage.writeln("Si l'utilisateur écrit en ANGLAIS, tu DOIS répondre en ANGLAIS.");
      systemMessage.writeln("JAMAIS d'exceptions à cette règle.");
      systemMessage.writeln("\nINSTRUCTION SYSTÈME (Tu es ce coach):");
      systemMessage.writeln(systemPrompt);
      systemMessage.writeln("\nSTYLE DE RÉPONSE:");
      systemMessage.writeln("- Sois CONCIS et DIRECT (max 3-4 phrases courtes)");
      systemMessage.writeln("- Donne UN exemple concret et réel à chaque fois");
      systemMessage.writeln("- Utilise le markdown pour structurer (gras pour mots-clés)");
      systemMessage.writeln("- Évite les longs paragraphes, préfère les listes courtes");
      systemMessage.writeln("- Tes réponses doivent être actionnables immédiatement");
      
      if (userContext.isNotEmpty) {
        systemMessage.writeln("\nCONTEXTE UTILISATEUR:");
        systemMessage.writeln(userContext);
      }
      
      messages.add({
        "role": "system",
        "content": systemMessage.toString(),
      });
      
      // Add user prompt
      messages.add({
        "role": "user",
        "content": prompt,
      });

      // Make API request
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': model,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle Bytez response format
        if (data['error'] != null) {
          return "Erreur Bytez: ${data['error']}";
        }
        
        // Extract output from response
        final output = data['output'] ?? data['choices']?[0]?['message']?['content'];
        return output ?? "Désolé, je n'ai pas pu générer de réponse.";
      } else {
        return "Erreur HTTP ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      print("Bytez Error: $e");
      return "Erreur de connexion à Bytez : $e";
    }
  }
}
