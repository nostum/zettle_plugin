import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_payment_response.dart';
import 'package:zettle_platform_interface/models/zettle_payment_request.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_refund_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_response.dart';
import 'package:zettle_platform_interface/models/zettle_refund_request.dart';
import 'package:zettle_platform_interface/zettle_platform_interface.dart';

/// An implementation of [ZettleIos] that uses method channels.
class ZettleIos extends ZettlePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel("zettle_ios");

  /// Registers this class as the default instance of [ZettlePlatform].
  static void registerWith() {
    ZettlePlatform.instance = ZettleIos();
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
    final response = await methodChannel.invokeMethod(
        "initialize", {'clientID': iosClientId, 'callbackURL': redirectUrl});
    return ZettlePluginResponse.fromMap(response!);
  }

  @override
  Future<ZettlePluginResponse> login() async {
    final response = await methodChannel.invokeMethod("login");
    return ZettlePluginResponse.fromMap(response!);
  }

  @override
  Future<ZettlePluginResponse> logout() async {
    final response = await methodChannel.invokeMethod("logout");
    return ZettlePluginResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginResponse> showSettings() async {
    final response = await methodChannel.invokeMethod("showSettings");
    return ZettlePluginResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginPaymentResponse> requestPayment(
      ZettlePaymentRequest paymentRequest) async {
    final response = await methodChannel.invokeMethod(
        "requestPayment", paymentRequest.toMap());
    return ZettlePluginPaymentResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginRefundResponse> requestRefund(
      ZettleRefundRequest refundRequest) async {
    final response = await methodChannel.invokeMethod(
        "requestRefund", refundRequest.toMap());
    return ZettlePluginRefundResponse.fromMap(response);
  }

  @override
  Future<ZettlePluginPaymentResponse> retrievePayment(String reference) async {
    final response = await methodChannel
        .invokeMethod("retrievePayment", {"reference": reference});
    return ZettlePluginPaymentResponse.fromMap(response);
  }
}
