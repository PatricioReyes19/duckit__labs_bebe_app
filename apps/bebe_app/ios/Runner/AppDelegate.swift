import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.duckitlabs.bebeapp/notification_permission",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "status":
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          let value: String
          switch settings.authorizationStatus {
          case .notDetermined:
            value = "notDetermined"
          case .denied:
            value = "permanentlyDenied"
          case .authorized, .provisional, .ephemeral:
            value = "granted"
          @unknown default:
            value = "unknown"
          }
          DispatchQueue.main.async { result(value) }
        }
      case "markRequested":
        result(nil)
      case "openSettings":
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
          result(false)
          return
        }
        UIApplication.shared.open(url) { opened in result(opened) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
