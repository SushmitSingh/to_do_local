import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBrowser();
  }
}

class MyBrowser extends StatefulWidget {
  const MyBrowser({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  MyBrowserState createState() => MyBrowserState();
}

class MyBrowserState extends State<MyBrowser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Terms And Condition"),
        ),
        body: const Center(
            // Look here!
            child: Webview(url: "https://sushmitsingh.github.io/idex.html")));
  }
}
