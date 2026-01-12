# Galacean Native Player

[![pub package](https://img.shields.io/pub/v/galacean_native_player.svg)](https://pub.dev/packages/galacean_native_player)

一个用于在 Flutter 中播放 [Galacean Effects](https://galacean.antgroup.com/effects) 的插件。

## 特性

- ✅ 支持 Android 和 iOS 平台
- ✅ 播放控制（播放、暂停、停止、重播）
- ✅ 循环播放和播放速度控制
- ✅ 状态监听和错误处理
- ✅ 支持本地和网络资源加载

## 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  galacean_native_player: ^0.6.0
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 基础使用

```dart
import 'package:galacean_native_player/galacean_native_player.dart';

class MyPlayerWidget extends StatefulWidget {
  @override
  _MyPlayerWidgetState createState() => _MyPlayerWidgetState();
}

class _MyPlayerWidgetState extends State<MyPlayerWidget> {
  late final GalaceanPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GalaceanPlayerController();
    
    // 监听状态变化
    _controller.stateStream.listen((state) {
      print('播放器状态: $state');
    });
    
    // 监听错误
    _controller.errorStream.listen((error) {
      print('播放器错误: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 播放器视图
        Expanded(
          child: GalaceanPlayerWidget(
            controller: _controller,
            placeholder: Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error) {
              return Center(child: Text('错误: $error'));
            },
          ),
        ),
        
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _controller.loadScene(
                  'https://example.com/effect.json',
                  autoPlay: true,
                );
              },
              child: Text('加载'),
            ),
            ElevatedButton(
              onPressed: () => _controller.play(),
              child: Text('播放'),
            ),
            ElevatedButton(
              onPressed: () => _controller.pause(),
              child: Text('暂停'),
            ),
            ElevatedButton(
              onPressed: () => _controller.stop(),
              child: Text('停止'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 控制器 API

```dart
// 加载特效资源
await controller.loadScene(url, autoPlay: true);

// 播放控制
await controller.play();
await controller.pause();
await controller.stop();
await controller.replay();

// 设置选项
await controller.setLoop(true);  // 循环播放
await controller.setSpeed(1.5);  // 播放速度

// 获取信息
double? currentTime = await controller.getCurrentTime();
double? duration = await controller.getDuration();

// 状态检查
bool isInitialized = controller.isInitialized;
bool isPlaying = controller.isPlaying;
GalaceanPlayerState state = controller.state;
```

## 平台集成

### Android

Android 平台的所有依赖（包括 `galaceanEffects.aar`、`libmarsnative.so`、`libc++_shared.so`）已经集成到插件中，**无需额外配置**。

#### 配置权限（如需加载网络资源）

在 `android/app/src/main/AndroidManifest.xml` 中添加网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

#### 添加 Galacean Effects SDK

在 `ios/Podfile` 中添加依赖：

```ruby
# TODO: 添加实际的 Galacean Effects iOS SDK
# pod 'GalaceanEffects', '~> x.x.x'
```

然后运行：

```bash
cd ios && pod install
```

#### 配置权限

在 `ios/Runner/Info.plist` 中添加必要的权限：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 示例

运行示例应用：

```bash
cd example
flutter run
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关链接

- [Galacean 官网](https://galacean.antgroup.com/)
- [Galacean Effects 文档](https://galacean.antgroup.com/effects)
- [Flutter 插件开发指南](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
