import 'package:zettle_platform_interface/models/zettle_payment_request.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_payment_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_refund_response.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_response.dart';
import 'package:zettle_platform_interface/models/zettle_refund_request.dart';
import 'package:zettle_platform_interface/zettle_platform_interface.dart';

ZettlePlatform get _platform => ZettlePlatform.instance;

class ZettlePlugin extends ZettlePlatform {
  @override
  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  @override
  Future<ZettlePluginResponse> initialize(
      {String? iosClientId,
      String? androidClientId,
      required String redirectUrl}) async {
    return await _platform.initialize(
        iosClientId: iosClientId,
        androidClientId: androidClientId,
        redirectUrl: redirectUrl);
  }

  @override
  Future<ZettlePluginResponse> showSettings() {
    return _platform.showSettings();
  }

  @override
  Future<ZettlePluginResponse> login() {
    return _platform.login();
  }

  @override
  Future<ZettlePluginResponse> logout() {
    return _platform.logout();
  }

  @override
  Future<ZettlePluginPaymentResponse> requestPayment(
      ZettlePaymentRequest paymentRequest) {
    return _platform.requestPayment(paymentRequest);
  }

  @override
  Future<ZettlePluginRefundResponse> requestRefund(
      ZettleRefundRequest refundRequest) {
    return _platform.requestRefund(refundRequest);
  }

  @override
  Future<ZettlePluginPaymentResponse> retrievePayment(String reference) {
    return _platform.retrievePayment(reference);
  }
}
