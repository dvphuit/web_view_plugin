package dvp.app.web_view_plugin

import android.content.Context
import android.util.Log
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
        channel = MethodChannel(binding.binaryMessenger, "web_view_plugin/method_channel").apply {
            setMethodCallHandler(this@NativeView)
        }
        view = MainWebView(context).apply {
            setMethodChannel(channel)
            
            (args["htmlData"] as String?)?.let {
                loadData(it, "text/html", "UTF-8")
            }

            (args["initUrl"] as String?)?.let {
                loadUrl(it)
            }
        }
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