import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'galacean_native_player_method_channel.dart';

abstract class GalaceanNativePlayerPlatform extends PlatformInterface {
  /// Constructs a GalaceanNativePlayerPlatform.
  GalaceanNativePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static GalaceanNativePlayerPlatform _instance = MethodChannelGalaceanNativePlayer();

  /// The default instance of [GalaceanNativePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelGalaceanNativePlayer].
  static GalaceanNativePlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GalaceanNativePlayerPlatform] when
  /// they register themselves.
  static set instance(GalaceanNativePlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }
}
