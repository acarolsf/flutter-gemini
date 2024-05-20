import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIManager {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;

  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  ];

  static final AIManager shared = AIManager._privateConstructor();

  AIManager._privateConstructor() {
    onInit();
  }

  void onInit() {
    var apiKey = dotenv.env['GEMINI_API_KEY'];
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey ?? "",
      generationConfig: GenerationConfig(maxOutputTokens: 100),
      safetySettings: safetySettings
    );
    _visionModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey ?? "",
      generationConfig: GenerationConfig(maxOutputTokens: 100),
      safetySettings: safetySettings
    );
    _chat = _model.startChat();
    debugPrint('init ai manager');

  }

  Future<Map<String, dynamic>> getAnswerFromAI(
      {String? file, required String text}) async {
    late final GenerateContentResponse response;

      var tokens = await countToken(text);

      if (tokens.totalTokens > 100) {
        return {};
      }

    if (file != null) {
      final firstImage = await (File(file).readAsBytes());
      final prompt = TextPart(text);
      final imageParts = [
        DataPart('image/jpeg', firstImage),
      ];
      response = await _visionModel.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
    } else {
      var content = Content.text(text.toString());
      response = await _chat.sendMessage(content);
    }

    return {
      'time': DateTime.now(),
      'message': response.text,
      'isSender': false,
      'isImage': false
    };
  }

  Future<Iterable<Content>> getHistory() async {
    var response = _chat.history.map((e) => e).toList();
    return response;
  }

  Future<CountTokensResponse> countToken(String prompt) async {
    final tokenCount = await _model.countTokens([Content.text(prompt)]);
    debugPrint('Token count: ${tokenCount.totalTokens}');
    return tokenCount;
  }
}
