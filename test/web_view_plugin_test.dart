import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_view_plugin/web_view_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('web_view_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await WebViewPlugin.platformVersion, '42');
  });
}
