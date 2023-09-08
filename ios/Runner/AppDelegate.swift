import UIKit
import Flutter

enum ChannelName {
  static let secure_screen = "com.ganeshaoperation.kreasi/secure_screen"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var field = UITextField()
  var isSecureScreen: Bool = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    // add Secure View
    addSecuredView()

    guard let controller : FlutterViewController = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not type FlutterViewController")
        }

    let secureChannel = FlutterMethodChannel(name: ChannelName.secure_screen,
                                                  binaryMessenger: controller.binaryMessenger)
    secureChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          switch call.method {
          case "setSecureScreen" :
            self?.setSecureScreen(isSecure: call.arguments as! Bool, result: result)
          default :
            result(FlutterMethodNotImplemented)
          }
        })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setSecureScreen(isSecure: Bool, result: FlutterResult) {
    isSecureScreen = isSecure
//     if (isSecure) {
//         // add Secure View
//         addSecuredView()
//     }
    secureView(willResign: false)
    result(isSecureScreen)
  }

  // Code to hide content if screen not active
  private func secureView(willResign: Bool) {
    print("SWIFT-SECURE-VIEW: " + String(isSecureScreen))
    if (willResign) {
        field.isSecureTextEntry = false
        self.window.isHidden = isSecureScreen
    } else {
        field.isSecureTextEntry = isSecureScreen
        self.window.isHidden = false
    }
  }

  override func applicationWillResignActive(
    _ application: UIApplication
  ) {
       print("SWIFT-SECURE-VIEW-WillResign: " + String(isSecureScreen))
       secureView(willResign: true)
//        field.isSecureTextEntry = false
//        self.window.isHidden = true
  }

  // Code to show content if screen active
  override func applicationDidBecomeActive(
    _ application: UIApplication
  ) {
       print("SWIFT-SECURE-VIEW-DidBecome: " + String(isSecureScreen))
       secureView(willResign: false)
//        field.isSecureTextEntry = true
//        self.window.isHidden = false
  }

  // Securing View Function
  private func addSecuredView() {
     if (!window.subviews.contains(field)) {
       window.addSubview(field)
       field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
       field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
       window.layer.superlayer?.addSublayer(field.layer)
       field.layer.sublayers?.first?.addSublayer(window.layer)
     }
  }
}