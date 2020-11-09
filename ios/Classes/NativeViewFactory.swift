//
//  NativeViewFactory.swift
//  Pods-Runner
//
//  Created by Fudesu on 11/9/20.
//

import Flutter
import UIKit

public class NativeViewFactory: NSObject, FlutterPlatformViewFactory {

    private var registrar: FlutterPluginRegistrar?

    init(registrar: FlutterPluginRegistrar?) {
        super.init()
        self.registrar = registrar
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
         FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as? NSDictionary
        let nativeView = NativeView(registrar: registrar!,
                withFrame: frame,
                viewIdentifier: viewId,
                arguments: arguments!)
        return nativeView
    }
}

