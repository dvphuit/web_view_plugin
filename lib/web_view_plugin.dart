import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const MethodChannel _method = const MethodChannel('web_view_plugin/method_channel');

typedef OnPageStarted = void Function(String url);
typedef OnPageFinished = void Function(String url);
typedef OnProgressChanged = void Function(int progress);

class WebViewPlugin extends StatelessWidget {
  WebViewPlugin({
    Key key,
    @required this.url,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgressChanged,
  });

  final String url;
  final OnPageStarted onPageStarted;
  final OnPageFinished onPageFinished;
  final OnProgressChanged onProgressChanged;
  final Map<String, dynamic> args = <String, dynamic>{};

  void _init() {
    args.putIfAbsent("initUrl", () => url);
    _method.setMethodCallHandler(_nativeMethodCallHandler);
  }

  Future<dynamic> _nativeMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onPageStarted":
        onPageStarted.call(call.arguments as String);
        break;
      case "onPageFinished":
        onPageFinished.call(call.arguments as String);
        break;
      case "onProgressChanged":
        onProgressChanged.call(call.arguments as int);
        break;
      default:
        return "Nothing";
        break;
    }
  }

  Widget build(BuildContext context) {
    final String viewType = 'web_view_plugin';
    _init();

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (BuildContext context, PlatformViewController controller) {
        if (Platform.isAndroid) {
          return AndroidViewSurface(
            controller: controller,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        } else {
          return UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: args,
            creationParamsCodec: const StandardMessageCodec(),
          );
        }
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
  }
}
