import 'package:flutter/services.dart';
import 'package:zettle_platform_interface/models/zettle_payment_request.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_payment_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_refund_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_response.dart';
import 'package:zettle_platform_interface/models/zettle_refund_request.dart';
import 'package:zettle_platform_interface/zettle_platform_interface.dart';
import 'package:flutter/foundation.dart';

class ZettleAndroid extends ZettlePlatform {
  static bool _isInitialized = false;

  @visibleForTesting
  final methodChannel = const MethodChannel('zettle_android');

  /// Registers this class as the default instance of [NaurtPlatform].
  static void registerWith() {
    ZettlePlatform.instance = ZettleAndroid();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<ZettlePluginResponse> initialize(
      {String? iosClientId,
      String? androidClientId,
      required String redirectUrl}) async {
    const String methodName = "initialize";
    if (_isInitialized) {
      return ZettlePluginResponse.fromMap({
        "methodName": methodName,
        "success": false,
        "errorMessage":
            "Zettle SDK is already initialized. You should only call Zettle.init() once"
      });
    }

    final response = await methodChannel.invokeMethod(methodName,
        {'androidClientId': androidClientId, 'redirect': redirectUrl});
    final zettleResponse = ZettlePluginResponse.fromMap(response);

    if (zettleResponse.success) {
      _isInitialized = true;
    }
    return zettleResponse;
  }

  @override
  Future<ZettlePluginResponse> showSettings() async {
    final response = await methodChannel.invokeMethod('showSettings');
    return ZettlePluginResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginResponse> login() async {
    final response = await methodChannel.invokeMethod('login');
    return ZettlePluginResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginResponse> logout() async {
    final response = await methodChannel.invokeMethod('logout');
    return ZettlePluginResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginPaymentResponse> requestPayment(
      ZettlePaymentRequest paymentRequest) async {
    final response = await methodChannel.invokeMethod(
        'requestPayment', paymentRequest.toMap());

    final zettleResponse = ZettlePluginResponse.fromMap(response);
    return ZettlePluginPaymentResponse.fromMap(
        zettleResponse.response as Map<dynamic, dynamic>);
  }

  @override
  Future<ZettlePluginRefundResponse> requestRefund(
      ZettleRefundRequest refundRequest) async {
    final response = await methodChannel.invokeMethod(
        'requestRefund', refundRequest.toMap());

    final zettleResponse = ZettlePluginResponse.fromMap(response);
    return ZettlePluginRefundResponse.fromMap(
        zettleResponse.response as Map<dynamic, dynamic>);
  }

  @override
  Future<ZettlePluginPaymentResponse> retrievePayment(String reference) async {
    final response = await methodChannel
        .invokeMethod('retrievePayment', {'reference': reference});

    final zettleResponse = ZettlePluginResponse.fromMap(response);
    return ZettlePluginPaymentResponse.fromMap(
        zettleResponse.response as Map<dynamic, dynamic>);
  }
}
