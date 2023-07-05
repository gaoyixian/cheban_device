import Flutter
import UIKit
import AdSupport

public class ChebanDevicePlugin: NSObject, FlutterPlugin {
  private var environment:String = ""
  private var suiteName:String? = nil
  private var launchOptions: [AnyHashable : Any] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cheban_device", binaryMessenger: registrar.messenger())
    let instance = ChebanDevicePlugin()
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var arguments: [String: AnyObject]
        if(call.arguments != nil){
            arguments = call.arguments as! [String: AnyObject]
        }else{
            arguments = [String: AnyObject]()
        }
        switch call.method{
        case "init":
            suiteName = arguments["suiteName"] as? String
            var res: [String: AnyObject] = [String: AnyObject]()
            res["environment"] = environment as AnyObject
            res["sandbox"] = ChebanDevicePlugin.isAppStoreReceiptSandbox as AnyObject
            res["testFlight"] = ChebanDevicePlugin.isTestFlight as AnyObject
            result(res)
        case "getHardwareDeviceID":
            result(getUUID())
        case "getEnvironment":
            result(environment)
        case "getISSandbox":
            result(ChebanDevicePlugin.isAppStoreReceiptSandbox)
        case "isTestFlight":
            result(ChebanDevicePlugin.isTestFlight)
        default:
            result(FlutterError(code: "404", message: "No such method", details: nil))
        }
  }
    
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
      // self.registerForRemoteNotifications()
      self.environment = UIApplication.shared.entitlements.value(forKey: .apsEnvironment) as? String ?? ""
      self.launchOptions = launchOptions
      return true
  }
    
  /// 是否是 testflight包
  public static var isTestFlight: Bool {
      return isAppStoreReceiptSandbox && !hasEmbeddedMobileProvision
  }
  
  /// 是否是 Appstore 包
  public static var isAppStore: Bool {
      return isAppStoreReceiptSandbox || hasEmbeddedMobileProvision ? false : true
  }
  
  fileprivate static var isAppStoreReceiptSandbox: Bool {
      return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  }
  
  fileprivate static var hasEmbeddedMobileProvision: Bool {
      return Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
  }

  func getUUID()->String{
      let serviceName = suiteName ?? ""
      let account = "cheban_ipfv"
      let UUIDData = SAMKeychain.passwordData(forService: serviceName, account: account)
      var UUID : NSString!
      if UUIDData != nil{
          UUID = NSString(data: UUIDData!, encoding: String.Encoding.utf8.rawValue)
      }
      if(UUID == nil){
          UUID = ASIdentifierManager.shared().advertisingIdentifier.uuidString as NSString
          if (UUID == nil || UUID == "00000000-0000-0000-0000-000000000000") {
              UUID = UIDevice.current.identifierForVendor?.uuidString as NSString?
          }
          SAMKeychain.setPassword(UUID! as String, forService: serviceName, account: account)
      }
      print("=====\(String(describing: UUID))")
      return UUID as String
  }
}