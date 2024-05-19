
import 'package:flutter/material.dart';
import 'package:flutter_gemini/managers/ai_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePresenter {
  
  List<Content> _chatHistory = [];

  List<Content> get chatHistory => _chatHistory;

  HomePresenter();

  Future<void> onLoad() async {
    _chatHistory = await AIManager.shared.getHistory().then((value) => value.toList());
    debugPrint(chatHistory.toString());
  }
}