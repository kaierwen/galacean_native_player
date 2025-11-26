import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galacean_native_player/galacean_native_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galacean Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _platformVersion = 'Unknown';
  String _sdkVersion = 'Unknown';
  final _galaceanPlugin = GalaceanNativePlayer();

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    String platformVersion;
    String sdkVersion;

    try {
      platformVersion = await _galaceanPlugin.getPlatformVersion() ?? 'Unknown';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      sdkVersion = await _galaceanPlugin.getSdkVersion() ?? 'Unknown';
    } on PlatformException {
      sdkVersion = 'Failed to get SDK version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _sdkVersion = sdkVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galacean Native Player'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildPlayerDemo(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '版本信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('平台版本', _platformVersion),
            const SizedBox(height: 8),
            _buildInfoRow('SDK 版本', _sdkVersion),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerDemo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '播放器演示',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerPage(),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('打开播放器'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final GalaceanPlayerController _controller;
  String _statusText = '未初始化';

  @override
  void initState() {
    super.initState();
    _controller = GalaceanPlayerController();

    // 监听状态变化
    _controller.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _statusText = _getStateText(state);
        });
      }
    });

    // 监听错误
    _controller.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('错误: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String _getStateText(GalaceanPlayerState state) {
    switch (state) {
      case GalaceanPlayerState.uninitialized:
        return '未初始化';
      case GalaceanPlayerState.loading:
        return '加载中...';
      case GalaceanPlayerState.ready:
        return '就绪';
      case GalaceanPlayerState.playing:
        return '播放中';
      case GalaceanPlayerState.paused:
        return '已暂停';
      case GalaceanPlayerState.stopped:
        return '已停止';
      case GalaceanPlayerState.error:
        return '错误';
      case GalaceanPlayerState.disposed:
        return '已销毁';
    }
  }

  Future<void> _loadScene() async {
    try {
      // TODO: 替换为实际的特效资源 URL
      await _controller.loadScene(
        'https://mdn.alipayobjects.com/mars/afts/file/A*WL2TTZ0DBGoAAAAAAAAAAAAAARInAQ',
        autoPlay: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('场景加载成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galacean 播放器'),
      ),
      body: Column(
        children: [
          // 播放器视图
          Expanded(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  GalaceanPlayerWidget(
                    controller: _controller,
                    placeholder: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorBuilder: (context, error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '播放器错误',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 状态栏
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text('状态: $_statusText'),
              ],
            ),
          ),

          // 控制按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.file_download,
                      label: '加载',
                      onPressed: _controller.isInitialized ? _loadScene : null,
                    ),
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      label: '播放',
                      onPressed: _controller.isInitialized
                          ? () => _controller.play()
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.pause,
                      label: '暂停',
                      onPressed: _controller.isInitialized
                          ? () => _controller.pause()
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.play_circle,
                      label: '恢复',
                      onPressed: _controller.isInitialized
                          ? () => _controller.resume()
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.stop,
                      label: '停止',
                      onPressed: _controller.isInitialized
                          ? () => _controller.stop()
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.replay,
                      label: '重播',
                      onPressed: _controller.isInitialized
                          ? () => _controller.replay()
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          iconSize: 32,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
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
