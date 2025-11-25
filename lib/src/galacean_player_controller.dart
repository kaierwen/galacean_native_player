import 'dart:async';
import 'package:flutter/services.dart';

/// Galacean 播放器状态
enum GalaceanPlayerState {
  /// 未初始化
  uninitialized,
  /// 加载中
  loading,
  /// 就绪
  ready,
  /// 播放中
  playing,
  /// 暂停
  paused,
  /// 停止
  stopped,
  /// 错误
  error,
  /// 已销毁
  disposed,
}

/// Galacean 播放器控制器
/// 
/// 用于控制 Galacean Effects 的播放、暂停、停止等操作
class GalaceanPlayerController {
  /// 方法通道
  MethodChannel? _channel;
  
  /// 播放器 ID
  int? _playerId;
  
  /// 当前状态
  GalaceanPlayerState _state = GalaceanPlayerState.uninitialized;
  
  /// 状态监听器
  final StreamController<GalaceanPlayerState> _stateController = 
      StreamController<GalaceanPlayerState>.broadcast();
  
  /// 错误监听器
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();

  /// 获取当前状态
  GalaceanPlayerState get state => _state;
  
  /// 状态流
  Stream<GalaceanPlayerState> get stateStream => _stateController.stream;
  
  /// 错误流
  Stream<String> get errorStream => _errorController.stream;
  
  /// 是否已初始化
  bool get isInitialized => _playerId != null && _state != GalaceanPlayerState.uninitialized;
  
  /// 是否正在播放
  bool get isPlaying => _state == GalaceanPlayerState.playing;

  /// 初始化播放器
  /// 
  /// [playerId] 播放器 ID，由 PlatformView 创建时传入
  Future<void> initialize(int playerId) async {
    _playerId = playerId;
    _channel = MethodChannel('galacean_native_player_$playerId');
    _channel!.setMethodCallHandler(_handleMethodCall);
    _updateState(GalaceanPlayerState.ready);
  }

  /// 加载特效资源
  /// 
  /// [url] 特效资源 URL，支持本地路径和网络地址
  /// [autoPlay] 加载完成后是否自动播放，默认为 true
  Future<void> loadScene(String url, {bool autoPlay = true}) async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      _updateState(GalaceanPlayerState.loading);
      await _channel!.invokeMethod('loadScene', {
        'url': url,
        'autoPlay': autoPlay,
      });
    } catch (e) {
      _updateState(GalaceanPlayerState.error);
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 播放
  Future<void> play() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('play');
      _updateState(GalaceanPlayerState.playing);
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 暂停
  Future<void> pause() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('pause');
      _updateState(GalaceanPlayerState.paused);
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 停止
  Future<void> stop() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('stop');
      _updateState(GalaceanPlayerState.stopped);
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 重新播放
  Future<void> replay() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('replay');
      _updateState(GalaceanPlayerState.playing);
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 设置循环播放
  /// 
  /// [loop] 是否循环播放
  Future<void> setLoop(bool loop) async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('setLoop', {'loop': loop});
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 设置播放速度
  /// 
  /// [speed] 播放速度，1.0 为正常速度
  Future<void> setSpeed(double speed) async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      await _channel!.invokeMethod('setSpeed', {'speed': speed});
    } catch (e) {
      _errorController.add(e.toString());
      rethrow;
    }
  }

  /// 获取当前播放进度（秒）
  Future<double?> getCurrentTime() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      final result = await _channel!.invokeMethod<double>('getCurrentTime');
      return result;
    } catch (e) {
      _errorController.add(e.toString());
      return null;
    }
  }

  /// 获取总时长（秒）
  Future<double?> getDuration() async {
    if (!isInitialized) {
      throw StateError('播放器未初始化');
    }
    
    try {
      final result = await _channel!.invokeMethod<double>('getDuration');
      return result;
    } catch (e) {
      _errorController.add(e.toString());
      return null;
    }
  }

  /// 处理来自原生端的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onStateChanged':
        final String stateStr = call.arguments as String;
        final newState = _parseState(stateStr);
        _updateState(newState);
        break;
      case 'onError':
        final String error = call.arguments as String;
        _updateState(GalaceanPlayerState.error);
        _errorController.add(error);
        break;
      case 'onLoadComplete':
        _updateState(GalaceanPlayerState.ready);
        break;
      case 'onPlayComplete':
        _updateState(GalaceanPlayerState.stopped);
        break;
      default:
        break;
    }
  }

  /// 更新状态
  void _updateState(GalaceanPlayerState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
    }
  }

  /// 解析状态字符串
  GalaceanPlayerState _parseState(String stateStr) {
    switch (stateStr.toLowerCase()) {
      case 'loading':
        return GalaceanPlayerState.loading;
      case 'ready':
        return GalaceanPlayerState.ready;
      case 'playing':
        return GalaceanPlayerState.playing;
      case 'paused':
        return GalaceanPlayerState.paused;
      case 'stopped':
        return GalaceanPlayerState.stopped;
      case 'error':
        return GalaceanPlayerState.error;
      default:
        return GalaceanPlayerState.uninitialized;
    }
  }

  /// 释放资源
  void dispose() {
    _updateState(GalaceanPlayerState.disposed);
    _stateController.close();
    _errorController.close();
    _channel = null;
    _playerId = null;
  }
}

