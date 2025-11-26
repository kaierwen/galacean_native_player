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

/// 特效资源列表
class EffectResource {
  final String name;
  final String url;
  final String description;

  const EffectResource({
    required this.name,
    required this.url,
    required this.description,
  });
}

const List<EffectResource> effectResources = [
  EffectResource(
    name: 'Heart 粒子',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*WL2TTZ0DBGoAAAAAAAAAAAAAARInAQ',
    description: '爱心粒子特效',
  ),
  EffectResource(
    name: '闪电球',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*D6TbS5ax2TgAAAAAAAAAAAAAARInAQ',
    description: '电光闪烁特效',
  ),
  EffectResource(
    name: '年兽大爆炸',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*TazWSbYr84wAAAAAAAAAAAAAARInAQ',
    description: '新年主题爆炸特效',
  ),
  EffectResource(
    name: '双十一鼓掌',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*e7_FTLA_REgAAAAAAAAAAAAAARInAQ',
    description: '购物节庆祝特效',
  ),
  EffectResource(
    name: '敬业福弹卡',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*D4ixTaUS-HoAAAAAAAAAAAAADlB4AQ',
    description: '集五福弹卡特效',
  ),
  EffectResource(
    name: '七夕福利倒计时',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*OW2VSKK3bWIAAAAAAAAAAAAADlB4AQ',
    description: '七夕节倒计时特效',
  ),
  EffectResource(
    name: '天猫 618',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*wIkMSokvwCgAAAAAAAAAAAAAARInAQ',
    description: '618 购物节特效',
  ),
  EffectResource(
    name: '年度账单',
    url:
        'https://mdn.alipayobjects.com/mars/afts/file/A*VtHiR4iOuxYAAAAAAAAAAAAAARInAQ',
    description: '年度账单特效（40s）',
  ),
];

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final GalaceanPlayerController _controller;
  String _statusText = '未初始化';
  int _selectedIndex = 0;
  bool _isFullscreen = false;
  bool _showFullscreenControls = true;
  Timer? _hideControlsTimer;

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

  Future<void> _loadScene([int? index]) async {
    final effectIndex = index ?? _selectedIndex;
    final effect = effectResources[effectIndex];

    try {
      await _controller.loadScene(
        effect.url,
        autoPlay: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${effect.name} 加载成功')),
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

  void _enterFullscreen() {
    setState(() {
      _isFullscreen = true;
      _showFullscreenControls = true;
    });
    // 进入全屏模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _startHideControlsTimer();
  }

  void _exitFullscreen() {
    _hideControlsTimer?.cancel();
    setState(() {
      _isFullscreen = false;
    });
    // 退出全屏模式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isFullscreen) {
        setState(() {
          _showFullscreenControls = false;
        });
      }
    });
  }

  void _toggleFullscreenControls() {
    setState(() {
      _showFullscreenControls = !_showFullscreenControls;
    });
    if (_showFullscreenControls) {
      _startHideControlsTimer();
    }
  }

  void _showEffectSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 拖动指示器
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text(
                        '选择特效',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${effectResources.length} 个特效',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // 特效列表
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: effectResources.length,
                    itemBuilder: (context, index) {
                      final effect = effectResources[index];
                      final isSelected = index == _selectedIndex;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          effect.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          effect.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : const Icon(Icons.play_circle_outline),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          Navigator.pop(context);
                          _loadScene(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEffect = effectResources[_selectedIndex];

    // 全屏模式
    if (_isFullscreen) {
      return _buildFullscreenView(currentEffect);
    }

    // 普通模式
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galacean 播放器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: '选择特效',
            onPressed: _showEffectSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前特效信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentEffect.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        currentEffect.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _showEffectSelector,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('切换'),
                ),
              ],
            ),
          ),

          // 播放器视图
          Expanded(
            child: GestureDetector(
              onDoubleTap: _enterFullscreen,
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    _buildPlayerWidget(),
                    // 全屏按钮
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: _enterFullscreen,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // 双击提示
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '双击全屏',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                const Spacer(),
                Text(
                  '${_selectedIndex + 1}/${effectResources.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // 控制按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 第一行：主要控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.skip_previous,
                      label: '上一个',
                      onPressed: _controller.isInitialized && _selectedIndex > 0
                          ? () {
                              setState(() {
                                _selectedIndex--;
                              });
                              _loadScene();
                            }
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.file_download,
                      label: '加载',
                      onPressed:
                          _controller.isInitialized ? () => _loadScene() : null,
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
                      icon: Icons.skip_next,
                      label: '下一个',
                      onPressed: _controller.isInitialized &&
                              _selectedIndex < effectResources.length - 1
                          ? () {
                              setState(() {
                                _selectedIndex++;
                              });
                              _loadScene();
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 第二行：辅助控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                    _buildControlButton(
                      icon: Icons.loop,
                      label: '循环',
                      onPressed: _controller.isInitialized
                          ? () => _controller.setLoop(true)
                          : null,
                    ),
                    _buildControlButton(
                      icon: Icons.list_alt,
                      label: '列表',
                      onPressed: _showEffectSelector,
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

  /// 构建全屏视图
  Widget _buildFullscreenView(EffectResource currentEffect) {
    return WillPopScope(
      onWillPop: () async {
        _exitFullscreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleFullscreenControls,
          onDoubleTap: _exitFullscreen,
          child: Stack(
            children: [
              // 播放器视图（全屏）
              Positioned.fill(
                child: _buildPlayerWidget(),
              ),

              // 控制层
              if (_showFullscreenControls) ...[
                // 顶部栏
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                          onPressed: _exitFullscreen,
                          tooltip: '退出全屏',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentEffect.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 底部控制栏
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一个
                        _buildFullscreenButton(
                          icon: Icons.skip_previous,
                          onPressed: _selectedIndex > 0
                              ? () {
                                  setState(() {
                                    _selectedIndex--;
                                  });
                                  _loadScene();
                                  _startHideControlsTimer();
                                }
                              : null,
                        ),
                        // 播放/暂停
                        StreamBuilder<GalaceanPlayerState>(
                          stream: _controller.stateStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data == GalaceanPlayerState.playing;
                            return _buildFullscreenButton(
                              icon: isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 48,
                              onPressed: () {
                                if (isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.resume();
                                }
                                _startHideControlsTimer();
                              },
                            );
                          },
                        ),
                        // 重播
                        _buildFullscreenButton(
                          icon: Icons.replay,
                          onPressed: () {
                            _controller.replay();
                            _startHideControlsTimer();
                          },
                        ),
                        // 下一个
                        _buildFullscreenButton(
                          icon: Icons.skip_next,
                          onPressed: _selectedIndex < effectResources.length - 1
                              ? () {
                                  setState(() {
                                    _selectedIndex++;
                                  });
                                  _loadScene();
                                  _startHideControlsTimer();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                // 双击提示
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '双击退出全屏',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 36,
  }) {
    return IconButton(
      icon: Icon(icon, color: onPressed != null ? Colors.white : Colors.white38),
      iconSize: size,
      onPressed: onPressed,
    );
  }

  /// 构建播放器 Widget（复用同一个实例）
  Widget _buildPlayerWidget() {
    return GalaceanPlayerWidget(
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
              const Text(
                '播放器错误',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
