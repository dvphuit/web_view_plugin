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
        var channelName = ""
        if let id = viewId as? Int64 {
            channelName = "web_view_plugin/method_channel/" + String(id)
        } else if let id = viewId as? String {
            channelName = "web_view_plugin/method_channel/" + id
        }
        
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        channel!.setMethodCallHandler(LeakAvoider(delegate: self).handle)

        let configuration = WKWebViewConfiguration()

        if #available(iOS 14.0, *) {
            configuration.limitsNavigationsToAppBoundDomains = true
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = preferences
            configuration.allowsInlineMediaPlayback = true
        } else {
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            configuration.preferences = preferences
            configuration.allowsInlineMediaPlayback = true
        }


        webView = MainWebView(frame: CGRect.zero, configuration: configuration, channel: channel)
        webView?.isOpaque = false
        webView?.backgroundColor = UIColor.clear
        webView?.cleanAllCookies()
        webView?.refreshCookies()
        
        
        let htmlData = args["htmlData"] as? String ?? ""
        if (!htmlData.isEmpty){
            webView?.loadHTMLString(htmlData, baseURL: nil)
        }
        
        let initialUrl = args["initUrl"] as? String ?? ""
        if (!initialUrl.isEmpty){
            let request = URLRequest(url: URL(string: initialUrl)!)
            webView?.load(request)
        }
       
    }

    public func view() -> UIView {
        webView ?? WKWebView()
    }

    public override func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? NSDictionary
        switch call.method {
        case "evaluateJavascript":
            let source = (arguments!["script"] as? String)!
            webView?.evaluateJavaScript(source, flutterResult: result)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }

}


