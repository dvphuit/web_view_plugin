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

/**
 * @author dvphu on 09,November,2020
 */

class MainWebView(context: Context) : WebView(context) {

    init {
        initView(context)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initView(context: Context) {
        this.settings.javaScriptEnabled = true
        this.settings.useWideViewPort = true
        this.settings.loadWithOverviewMode = true
        this.settings.domStorageEnabled = true
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
            Log.d("WebView", "loading progress $newProgress")
        }

    }
}