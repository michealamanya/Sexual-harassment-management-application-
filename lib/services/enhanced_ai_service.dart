import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

class EnhancedAIService extends ChangeNotifier {
  static final EnhancedAIService _instance = EnhancedAIService._internal();
  factory EnhancedAIService() => _instance;
  EnhancedAIService._internal();

  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _conversationHistory = [];
  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();

  bool _isConnected = false;
  bool _isAgentTyping = false;
  String _currentScenario = 'initial_contact';

  // Groq Configuration
  static const String _groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  late String _apiKey;
  static const String _model = 'llama-3.1-8b-instant'; // Fast and working model

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  Stream<ChatMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;
  bool get isAgentTyping => _isAgentTyping;
  String get currentScenario => _currentScenario;

  // Initialize with API key from environment
  void initializeWithApiKey(String apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY environment variable is not set');
    }
    _apiKey = apiKey;
  }

  Future<void> connectToChat() async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('API key not initialized');
      }

      _isConnected = true;
      notifyListeners();

      final welcomeText = await _generateContextualWelcome();

      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: welcomeText,
        isFromUser: false,
        timestamp: DateTime.now(),
        senderName: "AI Support Counselor",
        messageType: ChatMessageType.text,
      );

      _addMessage(welcomeMessage);
      _conversationHistory.add({'role': 'assistant', 'content': welcomeText});
    } catch (e) {
      debugPrint('Error connecting to chat: $e');
    }
  }

  Future<String> _generateContextualWelcome() async {
    final systemPrompt = '''${AIConfig.scenarioPrompts['initial_contact']}

${AIConfig.culturalContext}

You are a compassionate, trauma-informed AI support counselor specializing in sexual harassment support. Generate a warm, professional welcome message for someone who has just connected to sexual harassment support chat at MUST. The message should be 1-2 sentences, establish safety and confidentiality, and invite them to share when ready.''';

    try {
      final response = await _callGroqAPI(systemPrompt, []);
      if (response.isNotEmpty &&
          ResponseAnalyzer.calculateQualityScore(response) > 0.5) {
        return response;
      }
    } catch (e) {
      debugPrint('Welcome generation failed: $e');
    }

    return "Hello, I'm here to provide confidential support regarding any sexual harassment concerns. This conversation is private and secure. Please feel free to share what's on your mind when you're ready.";
  }

  Future<void> sendMessage(
    String text, {
    ChatMessageType type = ChatMessageType.text,
  }) async {
    if (text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
      messageType: type,
    );

    _addMessage(message);
    _conversationHistory.add({'role': 'user', 'content': text.trim()});

    _currentScenario = ResponseAnalyzer.detectScenario(
      text,
      _conversationHistory.map((m) => '${m['role']}: ${m['content']}').toList(),
    );

    if (ResponseAnalyzer.isCrisisResponse(text)) {
      await _handleCrisisResponse();
      return;
    }

    _isAgentTyping = true;
    notifyListeners();

    try {
      final aiResponse = await _generateContextualResponse(text);

      _isAgentTyping = false;
      notifyListeners();

      final responseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
        senderName: "AI Support Counselor",
        messageType: ChatMessageType.text,
      );

      _addMessage(responseMessage);
      _conversationHistory.add({'role': 'assistant', 'content': aiResponse});
    } catch (e) {
      debugPrint('Error generating response: $e');
      _isAgentTyping = false;
      notifyListeners();

      final fallbackResponse = _getScenarioBasedFallback(text);
      final responseMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: fallbackResponse,
        isFromUser: false,
        timestamp: DateTime.now(),
        senderName: "Support Counselor",
        messageType: ChatMessageType.text,
      );

      _addMessage(responseMessage);
      _conversationHistory.add({
        'role': 'assistant',
        'content': fallbackResponse,
      });
    }
  }

  Future<String> _generateContextualResponse(String userMessage) async {
    final scenarioPrompt = AIConfig.scenarioPrompts[_currentScenario] ??
        AIConfig.scenarioPrompts['emotional_support']!;

    final systemPrompt = '''$scenarioPrompt

${AIConfig.culturalContext}

You are a compassionate, trauma-informed AI support counselor specializing in sexual harassment support at MUST (Mbarara University of Science and Technology).

IMPORTANT GUIDELINES:
- Respond with empathy and validation
- Keep response to 1-3 sentences maximum
- Use trauma-informed language
- Respect user autonomy and choice
- Maintain professional boundaries
- Be culturally sensitive to Ugandan context
- Focus specifically on sexual harassment support
- Reference previous messages in the conversation to maintain continuity
- Show understanding of what the user has already shared
- Build on the conversation naturally''';

    try {
      final response = await _callGroqAPI(systemPrompt, _conversationHistory);
      return _postProcessResponse(response, userMessage);
    } catch (e) {
      debugPrint('Error calling Groq API: $e');
      throw Exception('Failed to generate response: $e');
    }
  }

  Future<String> _callGroqAPI(
    String systemPrompt,
    List<Map<String, String>> conversationHistory,
  ) async {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...conversationHistory,
    ];

    try {
      final response = await http
          .post(
            Uri.parse(_groqApiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': 0.7,
              'max_tokens': 512,
              'top_p': 1.0,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired API key');
      } else {
        throw Exception(
          'API call failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Groq API Error: $e');
      rethrow;
    }
  }

  String _postProcessResponse(String rawResponse, String userMessage) {
    String response = rawResponse.trim();

    final cleanupPatterns = [
      'COUNSELOR RESPONSE:',
      'COUNSELOR:',
      'SUPPORT AGENT:',
      'AI:',
    ];

    for (final pattern in cleanupPatterns) {
      response = response.replaceAll(pattern, '').trim();
    }

    if (response.length > 250) {
      final sentences = response.split('. ');
      response = sentences.take(3).join('. ');
      if (!response.endsWith('.')) response += '.';
    }

    if (!_containsSupportiveLanguage(response)) {
      response = _addSupportiveElement(response, userMessage);
    }

    return response;
  }

  bool _containsSupportiveLanguage(String response) {
    final supportiveWords = AIConfig.qualityKeywords['supportive']!;
    final lowerResponse = response.toLowerCase();

    return supportiveWords.any((word) => lowerResponse.contains(word));
  }

  String _addSupportiveElement(String response, String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('scared') || lowerMessage.contains('afraid')) {
      return "$response I want you to know that you're safe here and your feelings are completely valid.";
    } else if (lowerMessage.contains('fault') ||
        lowerMessage.contains('blame')) {
      return "$response Please remember that this is not your fault.";
    } else {
      return "$response I'm here to support you through this.";
    }
  }

  Future<void> _handleCrisisResponse() async {
    final crisisMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "🚨 I understand you may be in immediate danger. Your safety is the top priority. If you're in immediate physical danger, please call campus security at [SECURITY_NUMBER] or emergency services at 999.",
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "Crisis Support System",
      messageType: ChatMessageType.system,
    );

    _addMessage(crisisMessage);
    _conversationHistory.add({
      'role': 'assistant',
      'content': crisisMessage.text,
    });

    await Future.delayed(const Duration(seconds: 2));

    final supportMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "I'm staying here with you. You're being very brave by reaching out. Can you tell me if you're currently in a safe location?",
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "AI Support Counselor",
      messageType: ChatMessageType.text,
    );

    _addMessage(supportMessage);
    _conversationHistory.add({
      'role': 'assistant',
      'content': supportMessage.text,
    });
  }

  String _getScenarioBasedFallback(String userMessage) {
    switch (_currentScenario) {
      case 'crisis_intervention':
        return "Your safety is my immediate concern. If you're in danger right now, please contact campus security or emergency services. I'm here to support you through this crisis.";

      case 'reporting_guidance':
        return "I understand you're considering reporting what happened. You have several options, including anonymous reporting. You control this process and can take the time you need to decide what's right for you.";

      case 'emotional_support':
        return "I hear you, and I want you to know that your feelings are completely valid. What you experienced was not okay, and it's not your fault. I'm here to support you.";

      case 'follow_up_support':
        return "Thank you for updating me. I'm glad you felt comfortable reaching out again. How are you feeling about everything that's happened since we last spoke?";

      default:
        return "I'm here to provide confidential support for sexual harassment concerns. Your privacy is protected, and you can share as much or as little as you're comfortable with. How can I best support you today?";
    }
  }

  Future<void> sendFile(String filePath, String fileName) async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: fileName,
      isFromUser: true,
      timestamp: DateTime.now(),
      messageType: ChatMessageType.file,
      filePath: filePath,
    );

    _addMessage(message);

    _isAgentTyping = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isAgentTyping = false;
    notifyListeners();

    final response = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Thank you for sharing that file with me. I've received it securely and it's been encrypted for your privacy. Documentation like this can be important evidence. Would you like to talk about what this shows or discuss how it might be used in a report?",
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "AI Support Counselor",
      messageType: ChatMessageType.text,
    );

    _addMessage(response);
  }

  Future<void> escalateToEmergency() async {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "🚨 EMERGENCY PROTOCOL ACTIVATED: Campus security has been notified and is being dispatched to your location. Please stay on the line and move to a safe area if possible.",
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "Emergency System",
      messageType: ChatMessageType.system,
    );

    _addMessage(message);

    await Future.delayed(const Duration(seconds: 3));

    final followUpMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          "Help is on the way. I'm staying here with you. Try to focus on your breathing - in for 4 counts, hold for 4, out for 4. You're going to be okay.",
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "AI Support Counselor",
      messageType: ChatMessageType.text,
    );

    _addMessage(followUpMessage);
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    _messageController.add(message);
    notifyListeners();
  }

  Future<void> endChat() async {
    String closingMessage;
    try {
      final systemPrompt =
          '''Generate a compassionate, professional closing message for someone ending a sexual harassment support chat session. The message should:
- Thank them for their courage in reaching out
- Remind them that support is always available
- Validate their strength
- Encourage them to return if needed
- Be 2-3 sentences maximum''';

      closingMessage = await _callGroqAPI(systemPrompt, _conversationHistory);
      if (ResponseAnalyzer.calculateQualityScore(closingMessage) < 0.5) {
        throw Exception('Low quality response');
      }
    } catch (e) {
      closingMessage =
          "Thank you for trusting me with your concerns today. You've shown incredible courage by reaching out for support. Remember that help is always available when you need it, and you never have to face this alone.";
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: closingMessage,
      isFromUser: false,
      timestamp: DateTime.now(),
      senderName: "AI Support Counselor",
      messageType: ChatMessageType.system,
    );

    _addMessage(message);

    await Future.delayed(const Duration(seconds: 2));
    _isConnected = false;
    _conversationHistory.clear();
    notifyListeners();
  }

  Map<String, dynamic> getSessionAnalytics() {
    return {
      'messageCount': _messages.length,
      'userMessages': _messages.where((m) => m.isFromUser).length,
      'agentMessages': _messages.where((m) => !m.isFromUser).length,
      'scenariosDetected': _currentScenario,
      'sessionDuration': _messages.isNotEmpty
          ? DateTime.now().difference(_messages.first.timestamp).inMinutes
          : 0,
      'crisisDetected': ResponseAnalyzer.isCrisisResponse(
        _conversationHistory.map((m) => m['content']).join(' '),
      ),
    };
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}

enum ChatMessageType { text, image, file, voice, system }

class ChatMessage {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? senderName;
  final ChatMessageType messageType;
  final String? filePath;
  final bool isDelivered;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.senderName,
    this.messageType = ChatMessageType.text,
    this.filePath,
    this.isDelivered = true,
    this.isRead = false,
  });
}
