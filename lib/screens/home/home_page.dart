import 'package:flutter/material.dart';
import 'package:flutter_gemini/screens/home/home_presenter.dart';
import 'package:flutter_gemini/widgets/gradient_text.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _presenter = HomePresenter();

  @override
  void initState() {
    _presenter.onLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Chat bot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 243, 65, 252),
                        Color.fromARGB(255, 74, 116, 255),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0, left: 16.0),
                          child: Text(
                            "Hi! You Can Ask Me",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text(
                            "Anything",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 16.0, bottom: 16.0),
                          child: (TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/chat');
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              child: const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 16.0),
                                child: GradientText(
                                  "Ask Now",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  gradient: LinearGradient(colors: [
                                    Color.fromARGB(255, 246, 112, 244),
                                    Color.fromARGB(255, 72, 115, 255),
                                  ]),
                                ),
                              ))),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/icon.webp'),
                              scale: 0.5,
                              fit: BoxFit.fill),
                        ),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, left: 16),
              child: Text(
                'Recent Chats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              itemCount: _presenter.chatHistory.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                child: Text(_presenter.chatHistory[index].role ?? "", style: const TextStyle(fontSize: 16),),
              );
            })
          ],
        ),
      ),
    );
  }
}
