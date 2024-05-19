import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemini/screens/chat/chat_repository.dart';

abstract class ChatDelegate {
  scrollPage();
  updateWidgets();
}

class ChatPresenter {

  ChatPresenter({this.view}) {
    _repository = ChatRepository();
  }

  final ChatDelegate? view;
  late ChatRepository _repository;

  List<Map<String, dynamic>> chatHistory = [];
  String? file;

  Future<void> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    print(result);
    if (result != null) {
      file = result.files.first.path;
    }

    view?.updateWidgets();
  }

  Future<void> sendAnswer(String text) async {
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
    view?.scrollPage();
  }

  Future<void> getAnswerFromAI(String text) async {
    var response = await _repository.getAnswerFromAI(file: file, text: text);

    chatHistory.add(response);
    file = null;
  }
}
