import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:zettle_platform_interface/models/zettle_plugin_response.dart';

import 'zettle_platform_interface.dart';

/// An implementation of [ZettlePlatform] that uses method channels.
class MethodChannelZettlePlatformInterface extends ZettlePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zettle');

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
    final response =
        await methodChannel.invokeMethod<ZettlePluginResponse>('initialize', {
      'iosClientId': iosClientId,
      'androidClientId': androidClientId,
      'redirect': redirectUrl
    });
    return response!;
  }

  // @override
  // Future<ZettlePluginResponse> showSettings() async {
  //   final response =
  //       await methodChannel.invokeMethod<ZettlePluginResponse>('showSettings');
  //   return response!;
  // }
}
