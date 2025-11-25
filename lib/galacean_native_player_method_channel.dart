import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'galacean_native_player_platform_interface.dart';

/// An implementation of [GalaceanNativePlayerPlatform] that uses method channels.
class MethodChannelGalaceanNativePlayer extends GalaceanNativePlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('galacean_native_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getSdkVersion() async {
    final version = await methodChannel.invokeMethod<String>('getSdkVersion');
    return version;
  }
}
