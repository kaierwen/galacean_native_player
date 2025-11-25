# Galacean Effects Native SDK 集成指南

本文档详细说明如何将 Galacean Effects Native SDK 集成到 `galacean_native_player` 插件中。

## 概述

本插件已经提供了完整的 Flutter 层接口和原生平台框架代码，但需要开发者集成实际的 Galacean Effects Native SDK 才能实现真正的播放功能。

## 架构说明

```
┌─────────────────────────────────────────┐
│         Flutter Layer (Dart)            │
├─────────────────────────────────────────┤
│ GalaceanPlayerWidget                    │
│ GalaceanPlayerController                │
│ GalaceanPlayerPlatformInterface         │
└──────────────┬──────────────────────────┘
               │ MethodChannel
               │ PlatformView
┌──────────────┴──────────────────────────┐
│     Native Layer (Kotlin/Swift)         │
├─────────────────────────────────────────┤
│ Android: GalaceanPlayerView.kt          │
│ iOS: GalaceanPlayerView.swift           │
└──────────────┬──────────────────────────┘
               │
┌──────────────┴──────────────────────────┐
│    Galacean Effects Native SDK          │
│  (需要您集成的第三方 SDK)                  │
└─────────────────────────────────────────┘
```

## Android 平台集成

### 1. 添加 SDK 依赖

在 `android/build.gradle` 文件中添加 Galacean Effects SDK：

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    
    // TODO: 添加实际的 Galacean Effects Android SDK
    // 示例（请根据实际情况调整）：
    // implementation 'com.galacean:effects-android:1.0.0'
    // 或者使用本地 AAR 文件：
    // implementation files('libs/galacean-effects.aar')
}
```

### 2. 实现播放器逻辑

在 `android/src/main/kotlin/.../GalaceanPlayerView.kt` 中找到所有标记为 `TODO` 的位置，实现真实的播放器功能。

#### 主要实现点：

1. **初始化渲染视图**

```kotlin
// 在 init 方法中
private val surfaceView: GLSurfaceView = GLSurfaceView(context)
// 或者使用 TextureView
private val textureView: TextureView = TextureView(context)

init {
    container.addView(surfaceView, FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT
    ))
}
```

2. **初始化 Galacean Player**

```kotlin
// 示例代码（根据实际 SDK API 调整）
private var galaceanPlayer: GalaceanPlayer? = null

init {
    galaceanPlayer = GalaceanPlayer(context)
    galaceanPlayer?.setSurface(surfaceView)
    
    // 设置回调
    galaceanPlayer?.setOnStateChangedListener { state ->
        methodChannel.invokeMethod("onStateChanged", state.toString())
    }
    
    galaceanPlayer?.setOnErrorListener { error ->
        methodChannel.invokeMethod("onError", error)
    }
    
    galaceanPlayer?.setOnLoadCompleteListener {
        methodChannel.invokeMethod("onLoadComplete", null)
    }
}
```

3. **实现播放控制**

```kotlin
private fun loadScene(url: String, autoPlay: Boolean, result: MethodChannel.Result) {
    try {
        galaceanPlayer?.loadScene(url, object : LoadCallback {
            override fun onSuccess() {
                methodChannel.invokeMethod("onLoadComplete", null)
                if (autoPlay) {
                    play(null)
                }
                result.success(null)
            }
            
            override fun onError(error: String) {
                methodChannel.invokeMethod("onError", error)
                result.error("LOAD_FAILED", error, null)
            }
        })
    } catch (e: Exception) {
        result.error("LOAD_ERROR", e.message, null)
    }
}

private fun play(result: MethodChannel.Result?) {
    galaceanPlayer?.play()
    isPlaying = true
    methodChannel.invokeMethod("onStateChanged", "playing")
    result?.success(null)
}

private fun pause(result: MethodChannel.Result) {
    galaceanPlayer?.pause()
    isPlaying = false
    methodChannel.invokeMethod("onStateChanged", "paused")
    result.success(null)
}
```

4. **资源释放**

```kotlin
override fun dispose() {
    galaceanPlayer?.stop()
    galaceanPlayer?.release()
    galaceanPlayer = null
    methodChannel.setMethodCallHandler(null)
}
```

### 3. 配置 Proguard（如果使用）

在 `android/proguard-rules.pro` 中添加：

```proguard
# Galacean Effects SDK
-keep class com.galacean.** { *; }
```

## iOS 平台集成

### 1. 添加 SDK 依赖

在 `ios/galacean_native_player.podspec` 中添加依赖：

```ruby
Pod::Spec.new do |s|
  # ... 现有配置 ...
  
  # TODO: 添加 Galacean Effects iOS SDK 依赖
  # s.dependency 'GalaceanEffects', '~> 1.0.0'
  # 或者使用本地 framework：
  # s.vendored_frameworks = 'Frameworks/GalaceanEffects.framework'
end
```

或者在使用该插件的 iOS 项目的 `Podfile` 中添加：

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # TODO: 添加 Galacean Effects SDK
  # pod 'GalaceanEffects', '~> 1.0.0'
end
```

### 2. 实现播放器逻辑

在 `ios/Classes/GalaceanPlayerView.swift` 中找到所有标记为 `TODO` 的位置。

#### 主要实现点：

1. **初始化渲染视图**

```swift
// 在 init 方法中
private var renderView: GLKView?
// 或者使用 Metal
private var metalView: MTKView?

init(...) {
    // ...
    
    // 使用 GLKit
    renderView = GLKView(frame: _view.bounds)
    renderView?.backgroundColor = .clear
    _view.addSubview(renderView!)
    
    // 或者使用 Metal
    // metalView = MTKView(frame: _view.bounds, device: MTLCreateSystemDefaultDevice())
    // _view.addSubview(metalView!)
}
```

2. **初始化 Galacean Player**

```swift
// 示例代码（根据实际 SDK API 调整）
private var galaceanPlayer: GalaceanPlayer?

init(...) {
    // ...
    
    galaceanPlayer = GalaceanPlayer()
    galaceanPlayer?.setRenderView(renderView)
    
    // 设置回调
    galaceanPlayer?.onStateChanged = { [weak self] state in
        self?.methodChannel.invokeMethod("onStateChanged", arguments: state.toString())
    }
    
    galaceanPlayer?.onError = { [weak self] error in
        self?.methodChannel.invokeMethod("onError", arguments: error)
    }
    
    galaceanPlayer?.onLoadComplete = { [weak self] in
        self?.methodChannel.invokeMethod("onLoadComplete", arguments: nil)
    }
}
```

3. **实现播放控制**

```swift
private func loadScene(url: String, autoPlay: Bool, result: @escaping FlutterResult) {
    galaceanPlayer?.loadScene(url: url) { [weak self] success, error in
        guard let self = self else { return }
        
        if success {
            self.methodChannel.invokeMethod("onLoadComplete", arguments: nil)
            if autoPlay {
                self.play(result: nil)
            }
            result(nil)
        } else {
            let errorMsg = error ?? "Failed to load scene"
            self.methodChannel.invokeMethod("onError", arguments: errorMsg)
            result(FlutterError(code: "LOAD_FAILED", message: errorMsg, details: nil))
        }
    }
}

private func play(result: FlutterResult?) {
    galaceanPlayer?.play()
    isPlaying = true
    methodChannel.invokeMethod("onStateChanged", arguments: "playing")
    result?(nil)
}

private func pause(result: @escaping FlutterResult) {
    galaceanPlayer?.pause()
    isPlaying = false
    methodChannel.invokeMethod("onStateChanged", arguments: "paused")
    result(nil)
}
```

4. **资源释放**

```swift
deinit {
    galaceanPlayer?.stop()
    galaceanPlayer?.release()
    galaceanPlayer = nil
}
```

## 参考示例

### 从现有仓库获取示例

如果您有 `effects-native-examples` 或 `Effects Native` 仓库，可以参考其中的实现：

1. **查看 Android 实现**：
   - 播放器初始化代码
   - 资源加载逻辑
   - 渲染流程

2. **查看 iOS 实现**：
   - OpenGL/Metal 渲染设置
   - 播放器生命周期管理
   - 回调处理

### 常见 API 映射

根据 Galacean Effects 的标准 API，以下是常见的方法映射关系：

| Flutter 方法 | Android SDK | iOS SDK |
|------------|-------------|---------|
| `loadScene()` | `player.loadScene(url)` | `player.loadScene(url:)` |
| `play()` | `player.play()` | `player.play()` |
| `pause()` | `player.pause()` | `player.pause()` |
| `stop()` | `player.stop()` | `player.stop()` |
| `setLoop()` | `player.setLooping(bool)` | `player.isLooping = bool` |
| `setSpeed()` | `player.setSpeed(float)` | `player.playbackSpeed = float` |
| `getCurrentTime()` | `player.getCurrentTime()` | `player.currentTime` |
| `getDuration()` | `player.getDuration()` | `player.duration` |

## 测试

### 单元测试

插件已包含基本的单元测试框架，运行：

```bash
flutter test
```

### 集成测试

```bash
cd example
flutter test integration_test/
```

### 真机测试

```bash
# Android
flutter run -d <android-device-id>

# iOS
flutter run -d <ios-device-id>
```

## 常见问题

### Q: SDK 文件应该放在哪里？

**Android**:
- AAR 文件：`android/libs/`
- 通过 Gradle 依赖：在 `android/build.gradle` 中配置

**iOS**:
- Framework 文件：`ios/Frameworks/`
- 通过 CocoaPods：在 `ios/galacean_native_player.podspec` 中配置

### Q: 如何处理网络资源加载？

确保在 AndroidManifest.xml 和 Info.plist 中添加必要的网络权限。

### Q: 渲染性能如何优化？

1. 使用硬件加速（Android: GLSurfaceView, iOS: Metal）
2. 合理设置帧率
3. 避免在主线程进行重度计算

## 更多资源

- [Flutter 插件开发文档](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Android PlatformView 文档](https://docs.flutter.dev/development/platform-integration/android/platform-views)
- [iOS PlatformView 文档](https://docs.flutter.dev/development/platform-integration/ios/platform-views)
- [Galacean 官方文档](https://galacean.antgroup.com/)

## 技术支持

如果在集成过程中遇到问题，请：

1. 查看示例代码：`example/lib/main.dart`
2. 提交 Issue：https://github.com/kaierwen/galacean_native_player/issues
3. 参考 Galacean 官方文档

## 贡献

欢迎提交 PR 完善本插件！

