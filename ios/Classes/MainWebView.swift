//
// Created by Fudesu on 11/9/20.
//

import Flutter
import WebKit

public class MainWebView : WKWebView, WKNavigationDelegate {

    var channel: FlutterMethodChannel?

    init(frame: CGRect, configuration: WKWebViewConfiguration, channel: FlutterMethodChannel?) {
        super.init(frame: frame, configuration: configuration)
        self.channel = channel
        navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("page finished")
        channel?.invokeMethod("onPageFinished", arguments: nil)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("page started")
        channel?.invokeMethod("onPageStarted", arguments: nil)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let urlError = url?.absoluteString
        let arguments: [String: Any?] = ["url": urlError, "code": error._code, "message": error.localizedDescription]
        channel?.invokeMethod("onPageError", arguments: arguments)
    }

    public func evaluateJavaScript(_ javaScriptString: String, flutterResult: FlutterResult?) {
        if #available(iOS 14.0, *) {
//            let wkContentWorld = WKContentWorld.defaultClient
//            evaluateJavaScript(javaScriptString, in: nil, in: wkContentWorld, completionHandler: { result in
//                if flutterResult == nil {
//                    return
//                }
//
//                switch result {
//                    case .success(let message):
//                        flutterResult?(message)
//                    case .failure(_):
//                        return
//                }
//            })
        } else {
            evaluateJavaScript(javaScriptString, completionHandler: {(value, error) in
                if flutterResult == nil {
                    return
                }

                if value == nil {
                    flutterResult!(nil)
                    return
                }

                flutterResult!(value)
            })
        }

    }
}

extension WKWebView {

    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        if #available(iOS 9.0, *) {
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})

                }
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}