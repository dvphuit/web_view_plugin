//
// Created by Fudesu on 11/9/20.
//

import Flutter
import WebKit

public class MainWebView : WKWebView, WKUIDelegate, WKNavigationDelegate {

    var channel: FlutterMethodChannel?

    init(frame: CGRect, configuration: WKWebViewConfiguration, channel: FlutterMethodChannel?) {
        super.init(frame: frame, configuration: configuration)
        self.channel = channel
        navigationDelegate = self
        uiDelegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        channel?.invokeMethod("onPageFinished", arguments: nil)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        channel?.invokeMethod("onPageStarted", arguments: nil)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let urlError = url?.absoluteString
        let arguments: [String: Any?] = ["url": urlError, "code": error._code, "message": error.localizedDescription]
        channel?.invokeMethod("onPageError", arguments: arguments)
    }

    public func evaluateJavaScript(_ javaScriptString: String, flutterResult: FlutterResult?) {
        if #available(iOS 14.0, *) {
            let wkContentWorld = WKContentWorld.defaultClient
            
//            evaluateJavaScript(javaScriptString, in: nil, in: wkContentWorld, completionHandler: { result in
//                if flutterResult == nil {
//                    return
//                }
//                switch result {
//                    case .success(let message):
//                        flutterResult?(message)
//                    case .failure(_):
//                        return
//                }
//            })
            
            evaluateJavaScript(javaScriptString, in: nil, in: wkContentWorld, completionHandler: nil)
            
        } else {
            evaluateJavaScript(javaScriptString, completionHandler: nil)
//            evaluateJavaScript(javaScriptString, completionHandler: {(value, error) in
//                if flutterResult == nil {
//                    return
//                }
//
//                if value == nil {
//                    flutterResult!(nil)
//                    return
//                }
//
//                flutterResult!(value)
//            })
        }

    }
    
    public func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let title = NSLocalizedString("OK", comment: "OK Button")
            let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            webView.window?.rootViewController?.present(alert, animated: true)
            completionHandler()
        }
        
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
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
