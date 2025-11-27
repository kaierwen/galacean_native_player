import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'galacean_player_controller.dart';

/// Galacean 播放器 Widget
/// 
/// 用于显示和播放 Galacean Effects
class GalaceanPlayerWidget extends StatefulWidget {
  /// 播放器控制器（可选，如果不提供则内部创建）
  final GalaceanPlayerController? controller;
  
  /// 要播放的资源 URL（可选，如果提供则自动加载并播放）
  final String? url;
  
  /// 是否自动播放（仅在提供 url 时有效）
  final bool autoPlay;
  
  /// 加载时的占位 Widget
  final Widget? placeholder;
  
  /// 错误时的 Widget
  final Widget Function(BuildContext context, String error)? errorBuilder;

  const GalaceanPlayerWidget({
    super.key,
    this.controller,
    this.url,
    this.autoPlay = true,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  State<GalaceanPlayerWidget> createState() => _GalaceanPlayerWidgetState();
}

class _GalaceanPlayerWidgetState extends State<GalaceanPlayerWidget> {
  late final GalaceanPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    // 如果没有提供 controller，创建内部 controller
    if (widget.controller == null) {
      _controller = GalaceanPlayerController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // 播放器 ID 将在 PlatformView 创建时生成
    // 这里只是准备状态
    setState(() {
      _isInitialized = false;
    });
  }

  void _onPlatformViewCreated(int id) {
    _controller.initialize(id).then((_) {
      setState(() {
        _isInitialized = true;
      });
      
      // 如果提供了 url，自动加载并播放
      if (widget.url != null) {
        _loadAndPlay(widget.url!, widget.autoPlay);
      }
    }).catchError((e) {
      setState(() {
        _errorMessage = e.toString();
      });
    });
  }

  Future<void> _loadAndPlay(String url, bool autoPlay) async {
    try {
      await _controller.loadScene(url, autoPlay: autoPlay);
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void didUpdateWidget(GalaceanPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果 URL 改变了，重新加载
    if (widget.url != null && 
        widget.url != oldWidget.url && 
        _isInitialized && 
        _controller.isInitialized) {
      _loadAndPlay(widget.url!, widget.autoPlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _errorMessage!);
    }

    return Stack(
      children: [
        _buildPlatformView(),
        if (!_isInitialized && widget.placeholder != null)
          widget.placeholder!,
      ],
    );
  }

  Widget _buildPlatformView() {
    // 根据平台创建不同的 PlatformView
    if (Platform.isAndroid) {
      return _buildAndroidView();
    } else if (Platform.isIOS) {
      return _buildIOSView();
    } else {
      return Center(
        child: Text('不支持的平台: ${Platform.operatingSystem}'),
      );
    }
  }

  Widget _buildAndroidView() {
    return PlatformViewLink(
      viewType: 'galacean_native_player_view',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'galacean_native_player_view',
          layoutDirection: TextDirection.ltr,
          creationParams: <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();
      },
    );
  }

  Widget _buildIOSView() {
    return UiKitView(
      viewType: 'galacean_native_player_view',
      layoutDirection: TextDirection.ltr,
      creationParams: <String, dynamic>{},
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  @override
  void dispose() {
    // 如果是内部创建的 controller，需要销毁它
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }
}

