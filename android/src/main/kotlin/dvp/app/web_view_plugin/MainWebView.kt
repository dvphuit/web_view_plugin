package dvp.app.web_view_plugin

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import android.view.View
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import io.flutter.plugin.common.MethodChannel

/**
 * @author dvphu on 09,November,2020
 */

class MainWebView(context: Context) : WebView(context) {
    private var method: MethodChannel? = null

    init {
        initView(context)
    }

    fun setMethodChannel(method: MethodChannel?) {
        this.method = method
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initView(context: Context) {
        settings.apply {
            javaScriptEnabled = true
            useWideViewPort = true
            loadWithOverviewMode = true
            domStorageEnabled = true
        }
        webChromeClient = CustomChromeClient(context)
        webViewClient = CustomWebClient()
    }

    inner class CustomWebClient internal constructor() : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                Log.d("WebView", "loading url ${request?.url}")
            }
            return super.shouldOverrideUrlLoading(view, request)
        }

        override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
            super.onPageStarted(view, url, favicon)
            method?.invokeMethod("onPageStarted", url)
        }

        override fun onPageFinished(view: WebView?, url: String?) {
            super.onPageFinished(view, url)
            method?.invokeMethod("onPageFinished", url)
        }


    }

    inner class CustomChromeClient internal constructor(private val context: Context) : WebChromeClient() {
        private var mCustomView: View? = null
        private var mCustomViewCallback: CustomViewCallback? = null
        private var mOriginalSystemUiVisibility = 0
        private var orientation = resources.configuration.orientation

        override fun getDefaultVideoPoster(): Bitmap? {
            return if (mCustomView == null) {
                null
            } else BitmapFactory.decodeResource(context.resources, 2130837573)
        }

        override fun onHideCustomView() {
            currentActivity?.apply {
                (window.decorView as FrameLayout).apply {
                    removeView(mCustomView)
                    systemUiVisibility = mOriginalSystemUiVisibility
                }
                requestedOrientation = orientation
            }
            mCustomViewCallback?.onCustomViewHidden().also { mCustomViewCallback = null }
            mCustomView = null
        }

        override fun onShowCustomView(paramView: View?, paramCustomViewCallback: CustomViewCallback?) {
            if (mCustomView != null) {
                onHideCustomView()
                return
            }
            mCustomView = paramView
            currentActivity?.apply {
                requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
                (window.decorView as FrameLayout).apply {
                    mOriginalSystemUiVisibility = systemUiVisibility
                    addView(mCustomView, FrameLayout.LayoutParams(-1, -1))
                    systemUiVisibility = 3846
                }
            }
        }

        override fun onProgressChanged(view: WebView?, newProgress: Int) {
            super.onProgressChanged(view, newProgress)
            method?.invokeMethod("onProgressChanged", newProgress)
        }
    }
}