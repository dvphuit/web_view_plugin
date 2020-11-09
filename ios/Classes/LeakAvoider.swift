//
//  LeakAvoider.swift
//  flutter_native_webview
//
//  Created by Giovani Granero on 29/09/20.
//

import Flutter
import Foundation

public class LeakAvoider: NSObject {
    weak var delegate : FlutterMethodCallDelegate?

    init(delegate: FlutterMethodCallDelegate) {
        self.delegate = delegate
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.delegate?.handle(call, result: result)
    }

    deinit {

    }
}
