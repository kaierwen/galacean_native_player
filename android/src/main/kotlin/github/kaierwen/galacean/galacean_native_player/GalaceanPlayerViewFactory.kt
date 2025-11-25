package github.kaierwen.galacean.galacean_native_player

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Galacean Player View Factory
 * 用于创建 GalaceanPlayerView 实例
 */
class GalaceanPlayerViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return GalaceanPlayerView(context, viewId, messenger)
    }
}

