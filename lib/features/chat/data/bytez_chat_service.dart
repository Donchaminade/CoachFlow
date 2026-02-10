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
      systemMessage.writeln("INSTRUCTION SYSTÈME (Tu es ce coach):");
      systemMessage.writeln(systemPrompt);
      
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
