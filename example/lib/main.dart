
import 'package:flutter/material.dart';
import 'package:web_view_plugin/web_view_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebView Plugin'),
        ),
        body: WebViewPlugin(),
      ),
    );
  }
}
