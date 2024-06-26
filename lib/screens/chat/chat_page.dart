import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/screens/chat/chat_presenter.dart';
import 'package:gradient_borders/gradient_borders.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> implements ChatDelegate {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final _presenter = ChatPresenter(view: this);

  bool isLoading = false;

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
                itemCount: _presenter.chatHistory.length,
                shrinkWrap: false,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    child: Align(
                      alignment: (_presenter.chatHistory[index]["isSender"]
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
                          color: (_presenter.chatHistory[index]["isSender"]
                              ? Color.fromARGB(255, 165, 57, 243)
                              : Colors.white),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: _presenter.chatHistory[index]["isImage"]
                            ? Image.file(
                                File(_presenter.chatHistory[index]["message"]),
                                width: 200)
                            : Text(_presenter.chatHistory[index]["message"],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: _presenter.chatHistory[index]
                                            ["isSender"]
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
                height: _presenter.file == null ? 80 : 160,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        await _presenter.getFile();
                      },
                      minWidth: 42.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 243, 65, 252),
                                Color.fromARGB(255, 74, 116, 255),
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        ),
                        child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 42.0, minHeight: 36.0),
                            alignment: Alignment.center,
                            child: Icon(
                              _presenter.file == null
                                  ? Icons.image
                                  : Icons.check,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: _presenter.file != null,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  IconButton(
                                    onPressed: () => _presenter.removeImage(),
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black12,
                                      size: 50,
                                    ),
                                  ),
                                  Image.file(File(_presenter.file ?? ''),
                                      width: 100),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 45,
                            decoration: const BoxDecoration(
                              border: GradientBoxBorder(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromARGB(255, 252, 64, 245),
                                      Color.fromARGB(255, 61, 105, 247),
                                    ]),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
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
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    isLoading
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            onPressed: () async {
                              await _presenter.sendAnswer(_chatController.text);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            padding: const EdgeInsets.all(0.0),
                            child: Ink(
                              height: 42,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromARGB(255, 243, 65, 252),
                                      Color.fromARGB(255, 74, 116, 255),
                                    ]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
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

  @override
  scrollPage() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  updateWidgets() {
    setState(() {});
  }

  @override
  hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  clearText() {
    _chatController.clear();
  }
}
