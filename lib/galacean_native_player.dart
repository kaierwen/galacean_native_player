import 'galacean_native_player_platform_interface.dart';

export 'src/galacean_player_controller.dart';
export 'src/galacean_player_widget.dart';

/// Galacean Native Player Plugin
///
/// 用于在 Flutter 中播放 Galacean Effects 的插件
class GalaceanNativePlayer {
  /// 获取平台版本信息
  Future<String?> getPlatformVersion() {
    return GalaceanNativePlayerPlatform.instance.getPlatformVersion();
  }

  /// 获取 Galacean SDK 版本
  Future<String?> getSdkVersion() {
    return GalaceanNativePlayerPlatform.instance.getSdkVersion();
  }
}
