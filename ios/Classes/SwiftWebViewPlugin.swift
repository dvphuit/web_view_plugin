//
// Created by Fudesu on 11/9/20.
//

import Foundation
import  Flutter

public class SwiftWebViewPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = NativeViewFactory(registrar: registrar)
        registrar.register(factory, withId: "web_view_plugin")
    }
}

