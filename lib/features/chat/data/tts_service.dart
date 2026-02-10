import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _currentSpeakingMessageId;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Wait longer for TTS engine to be ready (Android needs more time)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Check if language is available
      final isAvailable = await _flutterTts.isLanguageAvailable("fr-FR");
      if (isAvailable == 0) {
        print("⚠️ French (fr-FR) not available, trying fr");
        final isFrAvailable = await _flutterTts.isLanguageAvailable("fr");
        if (isFrAvailable == 0) {
          print("❌ French language not available on this device");
          return;
        }
        await _flutterTts.setLanguage("fr");
      } else {
        await _flutterTts.setLanguage("fr-FR");
      }
      
      await _flutterTts.setSpeechRate(0.5); // Normal speed
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _currentSpeakingMessageId = null;
      });

      _flutterTts.setErrorHandler((msg) {
        print("❌ TTS Error: $msg");
        _currentSpeakingMessageId = null;
      });

      _isInitialized = true;
      print("✅ TTS Service initialized successfully");
    } catch (e) {
      print("❌ TTS initialization error: $e");
      _isInitialized = false;
    }
  }

  Future<void> speak(String text, String messageId) async {
    try {
      await _initialize();
      
      if (!_isInitialized) {
        print("⚠️ TTS not initialized, skipping speech");
        return;
      }
      
      // Stop current speech if any
      if (_currentSpeakingMessageId != null) {
        await stop();
      }

      // Clean Markdown syntax before speaking
      final cleanText = _cleanMarkdown(text);
      
      _currentSpeakingMessageId = messageId;
      final result = await _flutterTts.speak(cleanText);
      
      if (result == 1) {
        print("🔊 TTS speaking: ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...");
      } else {
        print("⚠️ TTS speak failed with result: $result");
        _currentSpeakingMessageId = null;
      }
    } catch (e) {
      print("❌ TTS speak error: $e");
      _currentSpeakingMessageId = null;
    }
  }

  /// Remove Markdown syntax for cleaner TTS output
  String _cleanMarkdown(String text) {
    String cleaned = text
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold **text**
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')     // Remove italic *text*
        .replaceAll(RegExp(r'__([^_]+)__'), r'$1')     // Remove bold __text__
        .replaceAll(RegExp(r'_([^_]+)_'), r'$1')       // Remove italic _text_
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')       // Remove code `text`
        .replaceAll(RegExp(r'```[^`]*```'), '')        // Remove code blocks
        .replaceAll(RegExp(r'^#+\s'), '')              // Remove headers #
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1'); // Remove links [text](url)
    
    // Remove list markers line by line
    return cleaned.split('\n')
        .map((line) => line.replaceAll(RegExp(r'^\s*[-*+]\s'), ''))
        .join('\n')
        .trim();
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _currentSpeakingMessageId = null;
    } catch (e) {
      print("❌ TTS stop error: $e");
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print("❌ TTS pause error: $e");
    }
  }

  bool isSpeaking(String messageId) {
    return _currentSpeakingMessageId == messageId;
  }

  String? get currentSpeakingId => _currentSpeakingMessageId;
}
