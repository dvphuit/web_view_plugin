package dvp.app.web_view_plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * @author dvphu on 09,November,2020
 */

internal class NativeView(
        context: Context,
        binding: FlutterPlugin.FlutterPluginBinding,
        args: Map<String?, Any?>)
    : PlatformView, MethodChannel.MethodCallHandler {

    private var channel: MethodChannel? = null
    private var view: MainWebView? = null


    init {
        view = MainWebView(context)
        channel = MethodChannel(binding.binaryMessenger, "web_view_plugin/method_channel").apply {
            setMethodCallHandler(this@NativeView)
        }
        view?.loadUrl(args["initUrl"] as String)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun dispose() {
        channel?.setMethodCallHandler(null)
    }

    override fun getView() = view
}