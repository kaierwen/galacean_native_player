package github.kaierwen.galacean.galacean_native_player

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

// TODO: 取消注释以下导入语句（需要确认正确的包名）
// import com.alibaba.gaiax.effects.GEPlayer
// import com.alibaba.gaiax.effects.GEPlayerParams
// import com.alibaba.gaiax.effects.listener.GEPlayerListener

/**
 * Galacean Player View
 * Android 端的播放器视图实现
 * 
 * 注意：由于 SDK 包名可能有变化，当前使用模拟实现
 * 需要根据实际的 SDK 包名进行调整
 * 
 * 参考文档：https://github.com/galacean/effects-native-examples
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
    
    // TODO: 取消注释以使用真实的 GEPlayer
    // private var gePlayer: GEPlayer? = null
    
    private var isPlaying = false
    private var isLooping = false
    private var playbackSpeed = 1.0
    private var currentSceneUrl: String? = null
    private var isInitialized = false

    init {
        // 创建方法通道
        methodChannel = MethodChannel(messenger, "galacean_native_player_$id")
        methodChannel.setMethodCallHandler(this)
        
        // 设置容器背景色
        container.setBackgroundColor(Color.TRANSPARENT)
        
        // 初始化播放器
        initializePlayer()
    }
    
    /**
     * 初始化播放器
     */
    private fun initializePlayer() {
        try {
            // TODO: 取消注释以下代码使用真实的 GEPlayer
            // 需要确认正确的包名和类名
            /*
            gePlayer = GEPlayer(context)
            
            gePlayer?.setPlayerListener(object : GEPlayerListener {
                override fun onPlayerReady(player: GEPlayer) {
                    Log.d(TAG, "Player ready")
                    isInitialized = true
                    invokeFlutterMethod("onStateChanged", "ready")
                }
                
                override fun onPlayerPlayStateChanged(player: GEPlayer, playing: Boolean) {
                    Log.d(TAG, "Play state changed: $playing")
                    isPlaying = playing
                    val state = if (playing) "playing" else "paused"
                    invokeFlutterMethod("onStateChanged", state)
                }
                
                override fun onPlayerEnd(player: GEPlayer) {
                    Log.d(TAG, "Player end")
                    isPlaying = false
                    invokeFlutterMethod("onStateChanged", "stopped")
                    invokeFlutterMethod("onPlayComplete", null)
                }
                
                override fun onPlayerError(player: GEPlayer, errorCode: Int, errorMsg: String) {
                    Log.e(TAG, "Player error: $errorCode - $errorMsg")
                    val error = "Error $errorCode: $errorMsg"
                    invokeFlutterMethod("onError", error)
                }
            })
            
            container.addView(gePlayer, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))
            */
            
            // 临时显示提示文本
            val textView = TextView(context)
            textView.text = "Galacean Player View\n等待 SDK 包名确认"
            textView.setTextColor(Color.WHITE)
            textView.textSize = 16f
            textView.gravity = android.view.Gravity.CENTER
            container.addView(textView)
            
            isInitialized = true
            Log.d(TAG, "Player initialized (mock mode)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize player", e)
            invokeFlutterMethod("onError", "Failed to initialize: ${e.message}")
        }
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
            
            // TODO: 取消注释以下代码使用真实的 GEPlayer
            /*
            val params = GEPlayerParams().apply {
                this.url = url
                this.autoPlay = autoPlay
                this.isLoop = isLooping
            }
            
            gePlayer?.load(params, object : GEPlayerListener {
                override fun onPlayerReady(player: GEPlayer) {
                    Log.d(TAG, "Scene loaded successfully")
                    invokeFlutterMethod("onLoadComplete", null)
                    result.success(null)
                }
                
                override fun onPlayerPlayStateChanged(player: GEPlayer, playing: Boolean) {
                    // 已在全局监听器中处理
                }
                
                override fun onPlayerEnd(player: GEPlayer) {
                    // 已在全局监听器中处理
                }
                
                override fun onPlayerError(player: GEPlayer, errorCode: Int, errorMsg: String) {
                    Log.e(TAG, "Failed to load scene: $errorCode - $errorMsg")
                    val error = "Load failed ($errorCode): $errorMsg"
                    invokeFlutterMethod("onError", error)
                    result.error("LOAD_FAILED", error, null)
                }
            })
            */
            
            // 临时模拟实现
            mainHandler.postDelayed({
                invokeFlutterMethod("onLoadComplete", null)
                if (autoPlay) {
                    isPlaying = true
                    invokeFlutterMethod("onStateChanged", "playing")
                }
                result.success(null)
            }, 500)
            
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
        if (!isInitialized) {
            result?.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Play")
            // TODO: gePlayer?.play()
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
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Pause")
            // TODO: gePlayer?.pause()
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
     * 停止
     */
    private fun stop(result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Stop")
            // TODO: gePlayer?.stop()
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
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Replay")
            // TODO: gePlayer?.stop(); gePlayer?.play()
            isPlaying = true
            invokeFlutterMethod("onStateChanged", "playing")
            result.success(null)
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
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Set loop: $loop")
            isLooping = loop
            // TODO: gePlayer?.setLoop(loop)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set loop error", e)
            val error = e.message ?: "Unknown error"
            result.error("SET_LOOP_ERROR", error, null)
        }
    }

    /**
     * 设置播放速度
     */
    private fun setSpeed(speed: Double, result: MethodChannel.Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Player not initialized", null)
            return
        }
        
        try {
            Log.d(TAG, "Set speed: $speed")
            playbackSpeed = speed
            // TODO: gePlayer?.setSpeed(speed.toFloat())
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set speed error", e)
            val error = e.message ?: "Unknown error"
            result.error("SET_SPEED_ERROR", error, null)
        }
    }

    /**
     * 获取当前播放时间
     */
    private fun getCurrentTime(result: MethodChannel.Result) {
        try {
            // TODO: val time = gePlayer?.getCurrentTime()?.toDouble() ?: 0.0
            val time = 0.0
            result.success(time)
        } catch (e: Exception) {
            Log.e(TAG, "Get current time error", e)
            result.error("GET_TIME_ERROR", e.message, null)
        }
    }

    /**
     * 获取总时长
     */
    private fun getDuration(result: MethodChannel.Result) {
        try {
            // TODO: val duration = gePlayer?.getDuration()?.toDouble() ?: 0.0
            val duration = 0.0
            result.success(duration)
        } catch (e: Exception) {
            Log.e(TAG, "Get duration error", e)
            result.error("GET_DURATION_ERROR", e.message, null)
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
        try {
            // TODO: gePlayer?.destroy(); gePlayer = null
            isInitialized = false
        } catch (e: Exception) {
            Log.e(TAG, "Error disposing player", e)
        }
        methodChannel.setMethodCallHandler(null)
    }
}

