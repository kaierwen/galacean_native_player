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
  /// 播放器控制器
  final GalaceanPlayerController controller;
  
  /// 加载时的占位 Widget
  final Widget? placeholder;
  
  /// 错误时的 Widget
  final Widget Function(BuildContext context, String error)? errorBuilder;

  const GalaceanPlayerWidget({
    super.key,
    required this.controller,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  State<GalaceanPlayerWidget> createState() => _GalaceanPlayerWidgetState();
}

class _GalaceanPlayerWidgetState extends State<GalaceanPlayerWidget> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
    widget.controller.initialize(id).then((_) {
      setState(() {
        _isInitialized = true;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = e.toString();
      });
    });
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
    super.dispose();
  }
}

