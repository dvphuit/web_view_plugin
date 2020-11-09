import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class WebViewPlugin extends StatelessWidget {
  final MethodChannel _channel = const MethodChannel('web_view_plugin/method_channel');
  final Map<String, dynamic> args = <String, dynamic>{};

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Widget build(BuildContext context) {
    final String viewType = 'web_view_plugin';

    // Pass parameters to the platform side.
    args.putIfAbsent("initUrl", () => "https://www.youtube.com");

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
          creationParamsCodec: StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener((id) {
            print("platform version: $platformVersion");
          })
          ..create();
      },
    );
  }
}
