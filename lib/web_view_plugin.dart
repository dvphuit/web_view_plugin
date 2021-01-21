import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// const MethodChannel _method = const MethodChannel('web_view_plugin/method_channel');

typedef OnPageStarted = void Function(String url);
typedef OnPageFinished = void Function(WebViewController webController);
typedef OnProgressChanged = void Function(int progress);

class WebViewPlugin extends StatelessWidget {
  WebViewPlugin({
    Key key,
    this.url,
    this.htmlData,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgressChanged,
  });

  final String url;
  final String htmlData;
  final OnPageStarted onPageStarted;
  final OnPageFinished onPageFinished;
  final OnProgressChanged onProgressChanged;
  final Map<String, dynamic> args = <String, dynamic>{};

  WebViewController _controller;

  void _init() {
    args.putIfAbsent("initUrl", () => url);
    args.putIfAbsent("htmlData", () => htmlData);
  }

  Widget build(BuildContext context) {
    final String viewType = 'web_view_plugin';
    _init();
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: args,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformCreated,
        layoutDirection: TextDirection.ltr,
        creationParams: args,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformCreated(int id) async {
    _controller = WebViewController(id, this);
  }
}

class WebViewController {
  MethodChannel _method;
  final int id;
  final WebViewPlugin _webView;

  WebViewController(this.id, this._webView) {
    _method = new MethodChannel('web_view_plugin/method_channel/$id');
    _method.setMethodCallHandler(nativeMethodCallHandler);
  }

  Future<dynamic> nativeMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onPageStarted":
        _webView?.onPageStarted.call(call.arguments as String);
        break;
      case "onPageFinished":
        _webView?.onPageFinished.call(this);
        break;
      case "onProgressChanged":
        _webView?.onProgressChanged.call(call.arguments as int);
        break;
      default:
        return "Nothing";
        break;
    }
  }

  Future<dynamic> evalJs({@required String script}) async {
    return await _method.invokeMethod('evaluateJavascript', {'script': script});
  }
}
