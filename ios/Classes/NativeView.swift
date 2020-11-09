//
// Created by Fudesu on 11/9/20.
//

import Flutter
import UIKit
import WebKit

class NativeView: FlutterMethodCallDelegate, FlutterPlatformView {

    private weak var registrar: FlutterPluginRegistrar?
    private var webView: MainWebView?
    private var viewId: Any = 0
    private var channel: FlutterMethodChannel?

    init(registrar: FlutterPluginRegistrar, withFrame frame: CGRect, viewIdentifier viewId: Any, arguments args: NSDictionary) {
        super.init()

        self.registrar = registrar
        self.viewId = viewId

        channel = FlutterMethodChannel(name: "web_view_plugin/method_channel", binaryMessenger: registrar.messenger())
        channel!.setMethodCallHandler(LeakAvoider(delegate: self).handle)

        let initialUrl = args["initUrl"] as! String?
        let url = initialUrl ?? "about:blank"

        let configuration = WKWebViewConfiguration()

        if #available(iOS 14.0, *) {
//            configuration.limitsNavigationsToAppBoundDomains = true
//            let preferences = WKWebpagePreferences()
//            preferences.allowsContentJavaScript = true
//            configuration.defaultWebpagePreferences = preferences
        } else {
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            configuration.preferences = preferences
            configuration.allowsInlineMediaPlayback = true
        }

        let request = URLRequest(url: URL(string: url)!)

        webView = MainWebView(frame: CGRect.zero, configuration: configuration, channel: channel)

        webView?.cleanAllCookies()
        webView?.refreshCookies()

        webView?.load(request)
    }

    public func view() -> UIView {
        webView ?? WKWebView()
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
        case "evaluateJavascript":
            let source = (arguments!["source"] as? String)!
            webView?.evaluateJavaScript(source, flutterResult: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

}


