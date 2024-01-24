import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/zettle_payment_request.dart';
import 'models/zettle_plugin_payment_response.dart';
import 'models/zettle_plugin_refund_response.dart';
import 'models/zettle_refund_request.dart';
import 'zettle_method_channel.dart';
import 'models/zettle_plugin_response.dart';

abstract class ZettlePlatform extends PlatformInterface {
  /// Constructs a ZettlePlatformInterfacePlatform.
  ZettlePlatform() : super(token: _token);

  static final Object _token = Object();

  static ZettlePlatform _instance = MethodChannelZettlePlatformInterface();

  /// The default instance of [ZettlePlatform] to use.
  ///
  /// Defaults to [MethodChannelZettlePlatformInterface].
  static ZettlePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZettlePlatform] when
  /// they register themselves.
  static set instance(ZettlePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ZettlePluginResponse> initialize(
      {String? iosClientId,
      String? androidClientId,
      required String redirectUrl}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<ZettlePluginResponse> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<ZettlePluginResponse> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  Future<ZettlePluginResponse> showSettings() {
    throw UnimplementedError('showSettings() has not been implemented.');
  }

  Future<ZettlePluginPaymentResponse> requestPayment(
      ZettlePaymentRequest paymentRequest) {
    throw UnimplementedError('requestPayment() has not been implemented.');
  }

  Future<ZettlePluginRefundResponse> requestRefund(
      ZettleRefundRequest refundRequest) {
    throw UnimplementedError('requestRefund() has not been implemented.');
  }

  Future<ZettlePluginPaymentResponse> retrievePayment(String reference) {
    throw UnimplementedError('requestRefund() has not been implemented.');
  }
}
