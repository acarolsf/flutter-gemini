import 'package:flutter_gemini/managers/ai_manager.dart';

class ChatRepository {

  ChatRepository();

  Future<Map<String, dynamic>> getAnswerFromAI(
      {String? file, required String text}) async {
    return await AIManager.shared.getAnswerFromAI(file: file, text: text);
  }
}
