
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
        body: WebViewPlugin(
          url: "https://www.youtube.com",
          onPageStarted: (url){
            print('on page started $url');
          },
          onPageFinished: (url){
            print('on page finished $url');
          },
          onProgressChanged: (progress){
            print('loading progress $progress');
          },
        ),
      ),
    );
  }
}
