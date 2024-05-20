import 'package:flutter_gemini/managers/ai_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatRepository {

  ChatRepository();

  Future<Map<String, dynamic>> getAnswerFromAI(
      {String? file, required String text}) async {
    return await AIManager.shared.getAnswerFromAI(file: file, text: text);
  }

  Future<List<Content>> getHistory() async {
    return await AIManager.shared.getHistory().then((value) => value.toList());
  }
}
