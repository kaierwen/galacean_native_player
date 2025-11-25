package github.kaierwen.galacean.galacean_native_player

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** GalaceanNativePlayerPlugin */
class GalaceanNativePlayerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

  companion object {
    const val SDK_VERSION = "1.0.0"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding
    
    // 注册方法通道
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "galacean_native_player")
    channel.setMethodCallHandler(this)
    
    // 注册 PlatformView
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(
        "galacean_native_player_view",
        GalaceanPlayerViewFactory(flutterPluginBinding.binaryMessenger)
      )
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getSdkVersion" -> {
        result.success(SDK_VERSION)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
