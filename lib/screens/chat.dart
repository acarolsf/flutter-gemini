import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gradient_borders/gradient_borders.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatHistory = [];
  String? _file;

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;

  @override
  void initState() {
    var apiKey = dotenv.env['GEMINI_API_KEY'];
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey ?? "");
    _visionModel =
        GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey ?? "");
    _chat = _model.startChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 160,
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: false,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    child: Align(
                      alignment: (_chatHistory[index]["isSender"]
                          ? Alignment.topRight
                          : Alignment.topLeft),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          color: (_chatHistory[index]["isSender"]
                              ? Color(0xFFF69170)
                              : Colors.white),
                        ),
                        padding: EdgeInsets.all(16),
                        child: _chatHistory[index]["isImage"]
                            ? Image.file(File(_chatHistory[index]["message"]),
                                width: 200)
                            : Text(_chatHistory[index]["message"],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: _chatHistory[index]["isSender"]
                                        ? Colors.white
                                        : Colors.black)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                        );
                        print(result);
                        if (result != null) {
                          setState(() {
                            _file = result.files.first.path;
                          });
                        }
                      },
                      minWidth: 42.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 42.0, minHeight: 36.0),
                            alignment: Alignment.center,
                            child: Icon(
                              _file == null ? Icons.image : Icons.check,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF69170),
                                  Color(0xFF7D96E6),
                                ]),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Type a message",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                            controller: _chatController,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (_chatController.text.isNotEmpty) {
                            if (_file != null) {
                              _chatHistory.add({
                                'time': DateTime.now(),
                                'message': _file,
                                'isSender': true,
                                'isImage': true
                              });
                            }

                            _chatHistory.add({
                              'time': DateTime.now(),
                              'message': _chatController.text,
                              'isSender': true,
                              'isImage': false
                            });
                          }
                        });

                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent
                        );

                        getAnswer(_chatController.text);
                        _chatController.clear();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF69170),
                                Color(0xFF7D96E6),
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 88.0,
                                minHeight:
                                    36.0), // min sizes for Material buttons
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void getAnswer(text) async {
    late final response;

    if(_file != null) {
      final firstImage = await (File(_file!).readAsBytes());
      final prompt = TextPart(text);
      final imageParts = [
        DataPart('image/jpeg', firstImage),
      ];

      response = await _visionModel.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);

      _file = null;
    } else {
      var content = Content.text(text.toString());
      response = await _chat.sendMessage(content);
    }

    setState(() {
      _chatHistory.add({
        'time': DateTime.now(),
        'message': response.text,
        'isSender': false,
        'isImage': false
      });
      _file = null;
    });

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent
    );
  }
}
