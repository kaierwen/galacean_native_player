import Flutter
import UIKit

/**
 * Galacean Player View Factory
 * 用于创建 GalaceanPlayerView 实例
 */
class GalaceanPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return GalaceanPlayerView(
            frame: frame,
            viewId: viewId,
            messenger: messenger,
            args: args
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

