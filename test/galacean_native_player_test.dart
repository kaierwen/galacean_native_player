import 'package:flutter_test/flutter_test.dart';
import 'package:galacean_native_player/galacean_native_player.dart';
import 'package:galacean_native_player/galacean_native_player_platform_interface.dart';
import 'package:galacean_native_player/galacean_native_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGalaceanNativePlayerPlatform
    with MockPlatformInterfaceMixin
    implements GalaceanNativePlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getSdkVersion() => Future.value('1.0.0');
}

void main() {
  final GalaceanNativePlayerPlatform initialPlatform = GalaceanNativePlayerPlatform.instance;

  test('$MethodChannelGalaceanNativePlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGalaceanNativePlayer>());
  });

  test('getPlatformVersion', () async {
    GalaceanNativePlayer galaceanNativePlayerPlugin = GalaceanNativePlayer();
    MockGalaceanNativePlayerPlatform fakePlatform = MockGalaceanNativePlayerPlatform();
    GalaceanNativePlayerPlatform.instance = fakePlatform;

    expect(await galaceanNativePlayerPlugin.getPlatformVersion(), '42');
  });
}
