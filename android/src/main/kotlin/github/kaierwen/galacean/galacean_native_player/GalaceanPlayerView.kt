package github.kaierwen.galacean.galacean_native_player

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.antgroup.galacean.effects.GEPlayer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Galacean Player View
 * Android 端的播放器视图实现，集成 Galacean Effects Native SDK
 * 
 * SDK 包名: com.antgroup.galacean.effects
 * 主要类: GEPlayer, GEPlayer.GEPlayerParams, GEPlayer.Callback
 */
class GalaceanPlayerView(
    private val context: Context,
    private val id: Int,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "GalaceanPlayerView"
    }

    private val container: FrameLayout = FrameLayout(context)
    private val methodChannel: MethodChannel
    private val mainHandler = Handler(Looper.getMainLooper())
    
    // Galacean Player 实例
    private var gePlayer: GEPlayer? = null
    
    private var isPlaying = false
    private var isLooping = false
    private var repeatCount = 0  // 0 表示无限循环，>0 表示播放次数
    private var playbackSpeed = 1.0
    private var currentSceneUrl: String? = null
    private var isInitialized = false
    private var isSceneLoaded = false

    init {
        // 创建方法通道
        methodChannel = MethodChannel(messenger, "galacean_native_player_$id")
        methodChannel.setMethodCallHandler(this)
        
        // 设置容器背景色
        container.setBackgroundColor(Color.TRANSPARENT)
        
        isInitialized = true
        Log.d(TAG, "GalaceanPlayerView created, id: $id")
    }

    override fun getView(): View {
        return container
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadScene" -> {
                val url = call.argument<String>("url")
                val autoPlay = call.argument<Boolean>("autoPlay") ?: true
                if (url != null) {
                    loadScene(url, autoPlay, result)
                } else {
                    result.error("INVALID_ARGUMENT", "URL cannot be null", null)
                }
            }
            "play" -> {
                play(result)
            }
            "pause" -> {
                pause(result)
            }
            "resume" -> {
                resume(result)
            }
            "stop" -> {
                stop(result)
            }
            "replay" -> {
                replay(result)
            }
            "setLoop" -> {
                val loop = call.argument<Boolean>("loop") ?: false
                setLoop(loop, result)
            }
            "setSpeed" -> {
                val speed = call.argument<Double>("speed") ?: 1.0
                setSpeed(speed, result)
            }
            "getCurrentTime" -> {
                getCurrentTime(result)
            }
            "getDuration" -> {
                getDuration(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * 加载场景
     */
    private fun loadScene(url: String, autoPlay: Boolean, result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            currentSceneUrl = url
            Log.d(TAG, "Loading scene: $url, autoPlay: $autoPlay")
            
            invokeFlutterMethod("onStateChanged", "loading")
            
            // 先销毁旧的播放器
            destroyPlayer()
            
            // 创建播放参数
            val params = GEPlayer.GEPlayerParams().apply {
                this.url = url
            }
            
            // 创建新的 GEPlayer
            gePlayer = GEPlayer(context, params)
            
            // 添加到容器
            container.removeAllViews()
            container.addView(gePlayer, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))
            
            // 加载场景
            gePlayer?.loadScene(object : GEPlayer.Callback {
                override fun onResult(success: Boolean, errorMsg: String?) {
                    mainHandler.post {
                        if (success) {
                            Log.d(TAG, "Scene loaded successfully")
                            isSceneLoaded = true
                            invokeFlutterMethod("onLoadComplete", null)
                            invokeFlutterMethod("onStateChanged", "ready")
                            
                            if (autoPlay) {
                                playInternal(null)
                            }
                            result.success(null)
                        } else {
                            Log.e(TAG, "Failed to load scene: $errorMsg")
                            isSceneLoaded = false
                            val error = errorMsg ?: "Unknown error"
                            invokeFlutterMethod("onError", error)
                            result.error("LOAD_FAILED", error, null)
                        }
                    }
                }
            })
            
        } catch (e: Exception) {
            Log.e(TAG, "Load scene exception", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result.error("LOAD_ERROR", error, null)
        }
    }

    /**
     * 播放
     */
    private fun play(result: MethodChannel.Result?) {
        playInternal(result)
    }
    
    /**
     * 内部播放方法
     */
    private fun playInternal(result: MethodChannel.Result?) {
        if (!isInitialized || gePlayer == null) {
            result?.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        if (!isSceneLoaded) {
            result?.error("SCENE_NOT_LOADED", "Scene not loaded yet", null)
            return
        }
        
        try {
            Log.d(TAG, "Play, repeatCount: $repeatCount")
            
            gePlayer?.play(repeatCount, object : GEPlayer.Callback {
                override fun onResult(success: Boolean, errorMsg: String?) {
                    mainHandler.post {
                        if (success) {
                            Log.d(TAG, "Play completed")
                            isPlaying = false
                            invokeFlutterMethod("onStateChanged", "stopped")
                            invokeFlutterMethod("onPlayComplete", null)
                        } else {
                            Log.e(TAG, "Play error: $errorMsg")
                            isPlaying = false
                            invokeFlutterMethod("onError", errorMsg ?: "Play failed")
                        }
                    }
                }
            })
            
            isPlaying = true
            invokeFlutterMethod("onStateChanged", "playing")
            result?.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Play error", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result?.error("PLAY_ERROR", error, null)
        }
    }

    /**
     * 暂停
     */
    private fun pause(result: MethodChannel.Result) {
        if (!isInitialized || gePlayer == null) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Pause")
            gePlayer?.pause()
            isPlaying = false
            invokeFlutterMethod("onStateChanged", "paused")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Pause error", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result.error("PAUSE_ERROR", error, null)
        }
    }

    /**
     * 恢复播放
     */
    private fun resume(result: MethodChannel.Result) {
        if (!isInitialized || gePlayer == null) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Resume")
            gePlayer?.resume()
            isPlaying = true
            invokeFlutterMethod("onStateChanged", "playing")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Resume error", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result.error("RESUME_ERROR", error, null)
        }
    }

    /**
     * 停止
     */
    private fun stop(result: MethodChannel.Result) {
        if (!isInitialized || gePlayer == null) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Stop")
            gePlayer?.stop()
            isPlaying = false
            invokeFlutterMethod("onStateChanged", "stopped")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Stop error", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result.error("STOP_ERROR", error, null)
        }
    }

    /**
     * 重新播放
     */
    private fun replay(result: MethodChannel.Result) {
        if (!isInitialized || gePlayer == null) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Replay")
            gePlayer?.stop()
            playInternal(result)
        } catch (e: Exception) {
            Log.e(TAG, "Replay error", e)
            val error = e.message ?: "Unknown error"
            invokeFlutterMethod("onError", error)
            result.error("REPLAY_ERROR", error, null)
        }
    }

    /**
     * 设置循环播放
     */
    private fun setLoop(loop: Boolean, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Set loop: $loop")
            isLooping = loop
            // 0 表示无限循环，1 表示播放一次
            repeatCount = if (loop) 0 else 1
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set loop error", e)
            val error = e.message ?: "Unknown error"
            result.error("SET_LOOP_ERROR", error, null)
        }
    }

    /**
     * 设置播放速度
     * 注意：当前 SDK 可能不支持此功能
     */
    private fun setSpeed(speed: Double, result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Set speed: $speed (not supported by SDK)")
            playbackSpeed = speed
            // SDK 可能不支持设置播放速度
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set speed error", e)
            val error = e.message ?: "Unknown error"
            result.error("SET_SPEED_ERROR", error, null)
        }
    }

    /**
     * 获取当前播放时间
     * 注意：SDK 没有提供此方法，返回 0
     */
    private fun getCurrentTime(result: MethodChannel.Result) {
        try {
            // SDK 没有提供获取当前时间的方法
            val time = 0.0
            result.success(time)
        } catch (e: Exception) {
            Log.e(TAG, "Get current time error", e)
            result.error("GET_TIME_ERROR", e.message, null)
        }
    }

    /**
     * 获取总时长
     * 可以通过 frameCount 估算
     */
    private fun getDuration(result: MethodChannel.Result) {
        try {
            val frameCount = gePlayer?.frameCount ?: 0
            // 假设 30fps，计算时长（秒）
            val duration = frameCount / 30.0
            result.success(duration)
        } catch (e: Exception) {
            Log.e(TAG, "Get duration error", e)
            result.error("GET_DURATION_ERROR", e.message, null)
        }
    }
    
    /**
     * 销毁播放器
     */
    private fun destroyPlayer() {
        try {
            gePlayer?.destroy()
            gePlayer = null
            isSceneLoaded = false
            isPlaying = false
        } catch (e: Exception) {
            Log.e(TAG, "Error destroying player", e)
        }
    }
    
    /**
     * 辅助方法：在主线程调用 Flutter 方法
     */
    private fun invokeFlutterMethod(method: String, arguments: Any?) {
        mainHandler.post {
            try {
                methodChannel.invokeMethod(method, arguments)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to invoke Flutter method: $method", e)
            }
        }
    }

    override fun dispose() {
        Log.d(TAG, "Disposing player")
        destroyPlayer()
        container.removeAllViews()
        methodChannel.setMethodCallHandler(null)
    }
}
