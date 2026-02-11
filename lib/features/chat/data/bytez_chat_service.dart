import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/chat_provider.dart';

class BytezChatService implements ChatService {
  final String apiKey;
  final String baseUrl = 'https://api.bytez.com/v1';
  final String model = 'google/gemma-3-1b-it';

  BytezChatService(this.apiKey);

  @override
  Future<String> getResponse(
    String prompt,
    String systemPrompt,
    String userContext, {
    Locale? locale,
  }) async {
    try {
      // Construct messages array with system context
      final messages = <Map<String, String>>[];
      
      // Determine language instruction based on locale
      final languageCode = locale?.languageCode ?? 'fr';
      final languageInstruction = languageCode == 'fr'
          ? 'TU DOIS RÉPONDRE UNIQUEMENT EN FRANÇAIS. JAMAIS EN ANGLAIS.'
          : 'YOU MUST RESPOND ONLY IN ENGLISH. NEVER IN FRENCH.';
      
      // Add system instruction as first message
      final systemMessage = StringBuffer();
      systemMessage.writeln("RÈGLE ABSOLUE - LANGUE:");
      systemMessage.writeln(languageInstruction);
      systemMessage.writeln("QUAND L'UTILISATEUR T'ÉCRIS, VAS DROIT AU BUT SANS TE PRÉSENTER.");
      systemMessage.writeln("\nINSTRUCTION SYSTÈME (TU ES CE COACH):");
      systemMessage.writeln(systemPrompt);
      systemMessage.writeln("\nSTYLE DE RÉPONSE:");
      systemMessage.writeln("- Sois CONCIS, DIRECT, REALISTE comme un COACH");
      systemMessage.writeln("- Donne UN exemple concret et réel à chaque fois");
      systemMessage.writeln("- Utilise le markdown pour structurer (gras pour mots-clés)");
      systemMessage.writeln("- Évite les longs paragraphes, PRÉFÈRE les listes courtes");
      systemMessage.writeln("- Tes réponses doivent être ACTIONNABLES IMMÉDIATEMENT");
      
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
