package dvp.app.web_view_plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * @author dvphu on 09,November,2020
 */

@Suppress("UNCHECKED_CAST")
internal class NativeViewFactory(private val binding: FlutterPlugin.FlutterPluginBinding)
    : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any): PlatformView {
        return NativeView(context, binding, args as Map<String?, Any?>)
    }
}