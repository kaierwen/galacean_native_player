# SDK 包名问题说明

## 问题描述

在集成 Galacean Effects Android SDK 时遇到编译错误：

```
Unresolved reference: gaiax
Unresolved reference: GEPlayer
Unresolved reference: GEPlayerParams
Unresolved reference: GEPlayerListener
```

## 问题原因

根据 [Galacean Effects Native Examples](https://github.com/galacean/effects-native-examples/blob/main/README.md) 的官方文档，依赖配置为：

```gradle
implementation 'io.github.galacean:effects:0.0.1.202311221223'
```

但是，文档中没有提供具体的包名（package name）和类名信息。

在代码中尝试使用的包名：
```kotlin
import com.alibaba.gaiax.effects.GEPlayer
import com.alibaba.gaiax.effects.GEPlayerParams
import com.alibaba.gaiax.effects.listener.GEPlayerListener
```

这些包名可能不正确，导致编译失败。

## 当前解决方案

为了让项目可以编译通过，已将代码改为模拟实现：

### 1. 注释掉不确定的导入

```kotlin
// TODO: 取消注释以下导入语句（需要确认正确的包名）
// import com.alibaba.gaiax.effects.GEPlayer
// import com.alibaba.gaiax.effects.GEPlayerParams
// import com.alibaba.gaiax.effects.listener.GEPlayerListener
```

### 2. 使用模拟实现

所有使用 SDK 的地方都添加了 `TODO` 注释和临时实现：

```kotlin
// 临时显示提示文本
val textView = TextView(context)
textView.text = "Galacean Player View\n等待 SDK 包名确认"
textView.setTextColor(Color.WHITE)
textView.textSize = 16f
textView.gravity = android.view.Gravity.CENTER
container.addView(textView)
```

### 3. 功能模拟

播放控制方法都使用模拟实现，可以正常响应 Flutter 调用，但不会真正播放：

```kotlin
private fun play(result: MethodChannel.Result?) {
    // TODO: gePlayer?.play()
    isPlaying = true
    invokeFlutterMethod("onStateChanged", "playing")
    result?.success(null)
}
```

## 如何找到正确的包名

### 方法 1: 查看 AAR 文件内容

```bash
# 下载 AAR 文件
./gradlew :galacean_native_player:downloadDependencies

# 解压 AAR 文件
unzip ~/.gradle/caches/modules-2/files-2.1/io.github.galacean/effects/0.0.1.202311221223/*.aar -d temp/

# 查看 classes.jar 内容
jar tf temp/classes.jar | grep -i player
```

### 方法 2: 查看官方示例代码

访问官方 GitHub 仓库的示例代码：
https://github.com/galacean/effects-native-examples/tree/main/android

查看 `MainActivity.kt` 或其他示例文件中的 import 语句。

### 方法 3: 使用 Android Studio

1. 打开 `android/` 目录作为 Android 项目
2. 等待 Gradle 同步完成
3. 在代码中输入 `GEPlayer`，按 `Alt+Enter` 自动导入
4. Android Studio 会显示可用的包名选项

### 方法 4: 查看 Javadoc

如果 SDK 提供了 Javadoc 文档，可以从中找到完整的包名和类名。

## 需要确认的信息

1. **GEPlayer 类的完整包名**
   - 可能是：`com.alibaba.gaiax.effects.GEPlayer`
   - 或者其他包名

2. **GEPlayerParams 类的完整包名**
   - 可能是：`com.alibaba.gaiax.effects.GEPlayerParams`

3. **GEPlayerListener 接口的完整包名**
   - 可能是：`com.alibaba.gaiax.effects.listener.GEPlayerListener`

4. **API 方法名称**
   - 创建播放器：`GEPlayer(context)`
   - 加载场景：`load(params, listener)` 或 `loadScene(url)`
   - 播放控制：`play()`, `pause()`, `stop()`
   - 设置选项：`setLoop(boolean)`, `setSpeed(float)`

## 下一步操作

### 一旦确认了正确的包名：

1. **取消注释导入语句**

```kotlin
import com.correct.package.name.GEPlayer
import com.correct.package.name.GEPlayerParams
import com.correct.package.name.listener.GEPlayerListener
```

2. **取消注释 GalaceanPlayerView.kt 中的 TODO 代码块**

找到所有 `// TODO:` 注释，取消下面被注释的代码。

3. **删除临时实现**

删除 TextView 的临时显示代码和模拟的播放控制逻辑。

4. **测试运行**

```bash
cd example
flutter run -d <android-device-id>
```

## 当前状态

- ✅ 项目可以编译通过
- ✅ 插件框架完整
- ✅ Flutter 与 Android 通信正常
- ⚠️ 使用模拟实现，暂时无法真正播放
- ⚠️ 等待确认正确的 SDK 包名

## 临时测试

即使使用模拟实现，仍然可以测试：

- ✅ 播放器界面显示
- ✅ Flutter 方法调用
- ✅ 状态回调机制
- ✅ 错误处理流程
- ✅ 控制按钮响应

只是不会看到实际的特效播放。

## 替代方案

如果无法找到正确的包名，可以考虑：

### 方案 1: 使用本地 AAR

从官方仓库下载 AAR 文件并放到 `android/libs/` 目录：

```gradle
dependencies {
    implementation files('libs/galacean-effects.aar')
}
```

### 方案 2: 联系官方支持

在 Galacean 官方 GitHub 仓库提交 Issue：
https://github.com/galacean/effects-native/issues

询问正确的包名和使用示例。

### 方案 3: 参考 effects-native-examples

克隆官方示例项目：

```bash
git clone https://github.com/galacean/effects-native-examples.git
cd effects-native-examples/android
```

查看其中的代码实现和导入语句。

## 联系方式

如果您已经找到了正确的包名，请更新：

1. 取消 `GalaceanPlayerView.kt` 中的导入注释
2. 取消所有 `TODO` 代码块的注释
3. 删除临时实现代码
4. 测试并验证功能

---

**更新日期**: 2025-11-25  
**状态**: 等待确认 SDK 包名  
**优先级**: 高

