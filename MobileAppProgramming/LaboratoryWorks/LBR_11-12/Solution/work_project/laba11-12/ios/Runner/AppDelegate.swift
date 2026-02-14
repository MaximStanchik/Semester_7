import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CBCentralManagerDelegate {
  private var centralManager: CBCentralManager?
  private var pendingResultForBluetooth: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    // Общий канал (bluetooth, launchBrowser)
    let channelCommon = FlutterMethodChannel(name: "demo.flutter/platform", binaryMessenger: controller.binaryMessenger)
    channelCommon.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getBluetoothStatus" {
            // используем CBCentralManager для проверки состояния
            self.pendingResultForBluetooth = result
            if self.centralManager == nil {
                self.centralManager = CBCentralManager(delegate: self, queue: nil)
            } else {
                // сразу вернуть текущее состояние
                result(self.centralManager?.state == .poweredOn)
                self.pendingResultForBluetooth = nil
            }
        } else if call.method == "launchBrowser" {
            if let args = call.arguments as? [String: Any], let urlString = args["url"] as? String, let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                result(true)
            } else {
                result(FlutterError(code: "BAD_ARGS", message: "URL missing", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // Отдельный канал для iOS battery
    let batteryChannel = FlutterMethodChannel(name: "demo.flutter/battery_ios", binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getBatteryLevel" {
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            if level < 0 {
                result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
            } else {
                result(Int(level * 100))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // Канал для Android-battery (чтобы Flutter-вызов не ломался на iOS)
    let batteryAndroidChannel = FlutterMethodChannel(name: "demo.flutter/battery_android", binaryMessenger: controller.binaryMessenger)
    batteryAndroidChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "getBatteryLevel" {
            // можно вернуть то же самое или сказать, что канал Android-специфичен.
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            if level < 0 {
                result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
            } else {
                result(Int(level * 100))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // CBCentralManagerDelegate
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    // если был ожидающий результат — вернуть состояние
    if let pending = pendingResultForBluetooth {
      pending(central.state == .poweredOn)
      pendingResultForBluetooth = nil
    }
  }
}
