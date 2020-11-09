#import "WebViewPlugin.h"
#if __has_include(<web_view_plugin/web_view_plugin-Swift.h>)
#import <web_view_plugin/web_view_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "web_view_plugin-Swift.h"
#endif

@implementation WebViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftWebViewPlugin registerWithRegistrar:registrar];
}
@end
