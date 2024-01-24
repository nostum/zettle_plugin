import 'package:flutter_test/flutter_test.dart';
import 'package:zettle_ios/zettle_ios.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zettle_platform_interface/models/zettle_refund_request.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_refund_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_payment_response.dart';
import 'package:zettle_platform_interface/models/zettle_payment_request.dart';
import 'package:zettle_platform_interface/zettle_method_channel.dart';
import 'package:zettle_platform_interface/zettle_platform_interface.dart';

class MockZettleIosPlatform
    with MockPlatformInterfaceMixin
    implements ZettlePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<ZettlePluginResponse> initialize(
      {String? iosClientId,
      String? androidClientId,
      required String redirectUrl}) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginResponse> login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginResponse> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginPaymentResponse> requestPayment(
      ZettlePaymentRequest paymentRequest) {
    // TODO: implement requestPayment
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginRefundResponse> requestRefund(
      ZettleRefundRequest refundRequest) {
    // TODO: implement requestRefund
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginResponse> showSettings() {
    // TODO: implement showSettings
    throw UnimplementedError();
  }

  @override
  Future<ZettlePluginPaymentResponse> retrievePayment(String reference) {
    // TODO: implement retrievePayment
    throw UnimplementedError();
  }
}

void main() {
  final ZettlePlatform initialPlatform = ZettlePlatform.instance;

  test('$MethodChannelZettlePlatformInterface is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelZettlePlatformInterface>());
  });

  test('getPlatformVersion', () async {
    ZettleIos zettleIosPlugin = ZettleIos();
    MockZettleIosPlatform fakePlatform = MockZettleIosPlatform();
    ZettlePlatform.instance = fakePlatform;

    expect(await zettleIosPlugin.getPlatformVersion(), '42');
  });
}
