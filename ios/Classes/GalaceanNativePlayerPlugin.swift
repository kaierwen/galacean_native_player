import Flutter
import UIKit

public class GalaceanNativePlayerPlugin: NSObject, FlutterPlugin {
  private static let sdkVersion = "1.0.0"
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "galacean_native_player", binaryMessenger: registrar.messenger())
    let instance = GalaceanNativePlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // 注册 PlatformView
    let factory = GalaceanPlayerViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "galacean_native_player_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getSdkVersion":
      result(GalaceanNativePlayerPlugin.sdkVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
