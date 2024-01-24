import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zettle_platform_interface/zettle_method_channel.dart';

void main() {
  MethodChannelZettlePlatformInterface platform =
      MethodChannelZettlePlatformInterface();
  const MethodChannel channel = MethodChannel('zettle_android');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
