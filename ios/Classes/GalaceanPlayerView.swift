import Flutter
import UIKit
import GalaceanEffects

/**
 * Galacean Player View
 * iOS 端的播放器视图实现，集成 Galacean Effects Native SDK
 *
 * SDK 类：GEPlayer, GEPlayerParams
 */
class GalaceanPlayerView: NSObject, FlutterPlatformView {
    private var containerView: UIView
    private var methodChannel: FlutterMethodChannel
    
    // Galacean Player 实例
    private var gePlayer: GEPlayer?
    private var playerParams: GEPlayerParams?
    
    private var isPlaying = false
    private var isLooping = false
    private var repeatCount: Int32 = 0  // 0 表示无限循环，>0 表示播放次数
    private var playbackSpeed: Double = 1.0
    private var currentSceneUrl: String?
    private var isSceneLoaded = false
    
    init(
        frame: CGRect,
        viewId: Int64,
        messenger: FlutterBinaryMessenger,
        args: Any?
    ) {
        containerView = UIView(frame: frame)
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true
        
        // 创建方法通道
        methodChannel = FlutterMethodChannel(
            name: "galacean_native_player_\(viewId)",
            binaryMessenger: messenger
        )
        
        super.init()
        
        // 设置方法调用处理
        methodChannel.setMethodCallHandler(handle)
        
        print("GalaceanPlayerView created, id: \(viewId)")
    }
    
    func view() -> UIView {
        return containerView
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadScene":
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                  message: "URL cannot be null",
                                  details: nil))
                return
            }
            let autoPlay = args["autoPlay"] as? Bool ?? true
            loadScene(url: url, autoPlay: autoPlay, result: result)
            
        case "play":
            play(result: result)
            
        case "pause":
            pause(result: result)
            
        case "resume":
            resume(result: result)
            
        case "stop":
            stop(result: result)
            
        case "replay":
            replay(result: result)
            
        case "setLoop":
            guard let args = call.arguments as? [String: Any],
                  let loop = args["loop"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                  message: "Loop parameter is required",
                                  details: nil))
                return
            }
            setLoop(loop: loop, result: result)
            
        case "setSpeed":
            guard let args = call.arguments as? [String: Any],
                  let speed = args["speed"] as? Double else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                  message: "Speed parameter is required",
                                  details: nil))
                return
            }
            setSpeed(speed: speed, result: result)
            
        case "getCurrentTime":
            getCurrentTime(result: result)
            
        case "getDuration":
            getDuration(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Player Control Methods
    
    /**
     * 加载场景
     */
    private func loadScene(url: String, autoPlay: Bool, result: @escaping FlutterResult) {
        currentSceneUrl = url
        print("Loading scene: \(url), autoPlay: \(autoPlay)")
        
        invokeFlutterMethod("onStateChanged", arguments: "loading")
        
        // 销毁旧的播放器
        destroyPlayer()
        
        // 创建播放参数
        playerParams = GEPlayerParams()
        playerParams?.url = url
        
        // 创建 GEPlayer
        gePlayer = GEPlayer(params: playerParams!)
        
        // 设置 frame 并添加到容器
        gePlayer?.frame = containerView.bounds
        gePlayer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(gePlayer!)
        
        // 加载场景
        gePlayer?.loadScene { [weak self] success, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    print("Scene loaded successfully")
                    self.isSceneLoaded = true
                    self.invokeFlutterMethod("onLoadComplete", arguments: nil)
                    self.invokeFlutterMethod("onStateChanged", arguments: "ready")
                    
                    if autoPlay {
                        self.playInternal(result: nil)
                    }
                    result(nil)
                } else {
                    print("Failed to load scene: \(errorMsg ?? "Unknown error")")
                    self.isSceneLoaded = false
                    let error = errorMsg ?? "Unknown error"
                    self.invokeFlutterMethod("onError", arguments: error)
                    result(FlutterError(code: "LOAD_FAILED",
                                      message: error,
                                      details: nil))
                }
            }
        }
    }
    
    /**
     * 播放
     */
    private func play(result: FlutterResult?) {
        playInternal(result: result)
    }
    
    /**
     * 内部播放方法
     */
    private func playInternal(result: FlutterResult?) {
        guard let player = gePlayer else {
            result?(FlutterError(code: "NOT_INITIALIZED",
                               message: "Player not initialized",
                               details: nil))
            return
        }
        
        guard isSceneLoaded else {
            result?(FlutterError(code: "SCENE_NOT_LOADED",
                               message: "Scene not loaded yet",
                               details: nil))
            return
        }
        
        print("Play, repeatCount: \(repeatCount)")
        
        player.play(withRepeatCount: repeatCount) { [weak self] success, errorMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    print("Play completed")
                    self.isPlaying = false
                    self.invokeFlutterMethod("onStateChanged", arguments: "stopped")
                    self.invokeFlutterMethod("onPlayComplete", arguments: nil)
                } else {
                    print("Play error: \(errorMsg ?? "Unknown error")")
                    self.isPlaying = false
                    self.invokeFlutterMethod("onError", arguments: errorMsg ?? "Play failed")
                }
            }
        }
        
        isPlaying = true
        invokeFlutterMethod("onStateChanged", arguments: "playing")
        result?(nil)
    }
    
    /**
     * 暂停
     */
    private func pause(result: @escaping FlutterResult) {
        guard let player = gePlayer else {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "Player not initialized",
                              details: nil))
            return
        }
        
        print("Pause")
        player.pause()
        isPlaying = false
        invokeFlutterMethod("onStateChanged", arguments: "paused")
        result(nil)
    }
    
    /**
     * 恢复播放
     */
    private func resume(result: @escaping FlutterResult) {
        guard let player = gePlayer else {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "Player not initialized",
                              details: nil))
            return
        }
        
        print("Resume")
        player.resume()
        isPlaying = true
        invokeFlutterMethod("onStateChanged", arguments: "playing")
        result(nil)
    }
    
    /**
     * 停止
     */
    private func stop(result: @escaping FlutterResult) {
        guard let player = gePlayer else {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "Player not initialized",
                              details: nil))
            return
        }
        
        print("Stop")
        player.stop()
        isPlaying = false
        invokeFlutterMethod("onStateChanged", arguments: "stopped")
        result(nil)
    }
    
    /**
     * 重新播放
     */
    private func replay(result: @escaping FlutterResult) {
        guard let player = gePlayer else {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "Player not initialized",
                              details: nil))
            return
        }
        
        print("Replay")
        player.stop()
        playInternal(result: result)
    }
    
    /**
     * 设置循环播放
     */
    private func setLoop(loop: Bool, result: @escaping FlutterResult) {
        print("Set loop: \(loop)")
        isLooping = loop
        // 0 表示无限循环，1 表示播放一次
        repeatCount = loop ? 0 : 1
        result(nil)
    }
    
    /**
     * 设置播放速度
     * 注意：当前 SDK 可能不支持此功能
     */
    private func setSpeed(speed: Double, result: @escaping FlutterResult) {
        print("Set speed: \(speed) (not supported by SDK)")
        playbackSpeed = speed
        // SDK 可能不支持设置播放速度
        result(nil)
    }
    
    /**
     * 获取当前播放时间
     * 注意：SDK 没有提供此方法，返回 0
     */
    private func getCurrentTime(result: @escaping FlutterResult) {
        // SDK 没有提供获取当前时间的方法
        let time = 0.0
        result(time)
    }
    
    /**
     * 获取总时长
     * 可以通过 frameCount 估算
     */
    private func getDuration(result: @escaping FlutterResult) {
        guard let player = gePlayer else {
            result(0.0)
            return
        }
        
        let frameCount = player.getFrameCount()
        // 假设 30fps，计算时长（秒）
        let duration = Double(frameCount) / 30.0
        result(duration)
    }
    
    // MARK: - Helper Methods
    
    /**
     * 销毁播放器
     */
    private func destroyPlayer() {
        gePlayer?.destroy()
        gePlayer?.removeFromSuperview()
        gePlayer = nil
        playerParams = nil
        isSceneLoaded = false
        isPlaying = false
    }
    
    /**
     * 辅助方法：调用 Flutter 方法
     */
    private func invokeFlutterMethod(_ method: String, arguments: Any?) {
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel.invokeMethod(method, arguments: arguments)
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        print("Disposing player")
        destroyPlayer()
    }
}
