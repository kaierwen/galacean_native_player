# 快速开始指南

## 🚀 5 分钟上手 Galacean Native Player

### 1. 添加依赖

在您的 Flutter 项目的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  galacean_native_player:
    git:
      url: https://github.com/kaierwen/galacean_native_player.git
      ref: main
```

运行：
```bash
flutter pub get
```

### 2. 创建播放器

```dart
import 'package:flutter/material.dart';
import 'package:galacean_native_player/galacean_native_player.dart';

class MyPlayerPage extends StatefulWidget {
  @override
  _MyPlayerPageState createState() => _MyPlayerPageState();
}

class _MyPlayerPageState extends State<MyPlayerPage> {
  late final GalaceanPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GalaceanPlayerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Galacean Player')),
      body: Column(
        children: [
          // 播放器视图
          Expanded(
            child: GalaceanPlayerWidget(
              controller: _controller,
            ),
          ),
          
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _controller.loadScene(
                  'https://your-scene-url.json',
                ),
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
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 3. 运行示例

查看完整的示例应用：

```bash
cd example
flutter run
```

### 4. 集成 Galacean SDK（重要！）

⚠️ **注意**：本插件提供了完整的框架，但需要您集成实际的 Galacean Effects SDK 才能播放。

详细步骤请查看：
- 📖 [集成指南 (INTEGRATION_GUIDE.md)](./INTEGRATION_GUIDE.md)
- 📖 [完整文档 (README.md)](./README.md)

### 5. 常用 API

```dart
// 加载场景
await controller.loadScene('url', autoPlay: true);

// 播放控制
await controller.play();
await controller.pause();
await controller.stop();
await controller.replay();

// 设置选项
await controller.setLoop(true);
await controller.setSpeed(1.5);

// 监听状态
controller.stateStream.listen((state) {
  print('播放器状态: $state');
});

// 监听错误
controller.errorStream.listen((error) {
  print('播放器错误: $error');
});
```

## 📱 支持的平台

- ✅ Android
- ✅ iOS

## 🔗 相关链接

- [GitHub 仓库](https://github.com/kaierwen/galacean_native_player)
- [完整文档](./README.md)
- [集成指南](./INTEGRATION_GUIDE.md)
- [项目总结](./PROJECT_SUMMARY.md)
- [Galacean 官网](https://galacean.antgroup.com/)

## ❓ 遇到问题？

1. 查看 [集成指南](./INTEGRATION_GUIDE.md)
2. 查看 [示例代码](./example/lib/main.dart)
3. 提交 [GitHub Issue](https://github.com/kaierwen/galacean_native_player/issues)

## 📝 下一步

- [ ] 集成 Galacean Effects SDK
- [ ] 运行示例应用测试
- [ ] 根据需求定制功能
- [ ] 反馈问题和建议

祝您使用愉快！🎉

