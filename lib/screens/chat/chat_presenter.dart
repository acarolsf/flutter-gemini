import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/screens/chat/chat_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class ChatDelegate {
  showLoading();
  hideLoading();
  clearText();
  scrollPage();
  updateWidgets();
}

class ChatPresenter {

  ChatPresenter({this.view}) {
    _repository = ChatRepository();
    getHistory();
  }

  final ChatDelegate? view;
  late ChatRepository _repository;

  bool isLoading = false;

  List<Map<String, dynamic>> chatHistory = [];
  String? file;

  void removeImage() {
    debugPrint('remove image');
    file = null;
    view?.updateWidgets();
  }

  Future<void> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    debugPrint(result?.files.first.path);
    if (result != null) {
      file = result.files.first.path;
    }

    view?.updateWidgets();
  }

  Future<void> sendAnswer(String text) async {
    view?.showLoading();
    view?.clearText();

    if (text.isNotEmpty) {
      if (file != null) {
        chatHistory.add({
          'time': DateTime.now(),
          'message': file,
          'isSender': true,
          'isImage': true
        });
      }

      chatHistory.add({
        'time': DateTime.now(),
        'message': text,
        'isSender': true,
        'isImage': false
      });

      view?.scrollPage();
    }

    await getAnswerFromAI(text);

    view?.updateWidgets();
    view?.hideLoading();
  }

  Future<void> getAnswerFromAI(String text) async {
    var response = await _repository.getAnswerFromAI(file: file, text: text);

    chatHistory.add(response);
    file = null;
    view?.updateWidgets();
    view?.scrollPage();
  }

  Future<void> getHistory() async {
    debugPrint('get history');
    var response = await _repository.getHistory();

    response.forEach((element) {
      var message = element.parts.first as TextPart;
      debugPrint(message.text);
      chatHistory.add({
        'time': DateTime.now(),
        'message': message.text,
        'isSender': element.role == 'user',
        'isImage': false
      });
    });

    view?.updateWidgets();
    view?.scrollPage();
  }
}
