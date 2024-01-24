import iZettleSDK


import Flutter
import UIKit

/// A Flutter plugin for integrating Zettle functionality on iOS.
public class ZettleIosPlugin: NSObject, FlutterPlugin {
    
  
  static var isInitialized = false
    
    
  /// The method that initializes the Zettle iOS plugin.
  ///
  /// This method should be called when your Flutter app starts to set up the Zettle plugin.
  /// It registers the Zettle plugin with the Flutter engine.
  ///
  /// - Parameters:
  ///   - registrar: A `FlutterPluginRegistrar` instance that manages the registration of the plugin with Flutter.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zettle_ios", binaryMessenger: registrar.messenger())
    let instance = ZettleIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  /// A utility method to retrieve the topmost view controller in the application's view hierarchy.
  private func topController() -> UIViewController{
        return UIApplication.shared.keyWindow!.rootViewController!;
  }
    

  /// The entry point for the Flutter plugin.
  ///
  /// This method is called when the Flutter engine connects to the plugin.
  /// - Parameter call: A `FlutterMethodCall` instance representing the method call from Flutter.
  /// - Parameter result: A closure to invoke with the result of the method call.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch(call.method){
      case "getPlatformVersion":
        result("iOS" + UIDevice.current.systemVersion)
        break;
      case "initialize":
        let arguments = call.arguments as! Dictionary<String, Any>
        result(self.initSDK(arguments: arguments).toDict());
        break;
      case "login":
        self.showSettings()
        let response = ZettlePluginResponse(methodName: call.method, success: true);
        result(response.toDict())
        break;
      case "showSettings":
        self.showSettings()
        let response = ZettlePluginResponse(methodName: call.method, success: true);
        result(response.toDict())
        break;
      case "logout":
        self.logout()
        let response = ZettlePluginResponse(methodName: call.method, success: true);
        result(response.toDict())
        break;
      case "requestPayment":
        let args = call.arguments as! Dictionary<String, Any>
        PaymentService(viewController: topController()).requestPayment(requestPayment: args) { response in
            result(response)
        }
      case "retrievePayment":
        let args = call.arguments as! Dictionary<String, Any>
        PaymentService(viewController: topController()).retrievePayment(paymentReference: args) { response in
            result(response)
        }
      case "requestRefund":
        let args = call.arguments as! Dictionary<String, Any>
        PaymentService(viewController: topController()).refundPayment(requestRefund: args) { response in
            result(response)
        }
      default:
        result(FlutterMethodNotImplemented)
    }

  }
    
  /// Initializes the SDK with the provided arguments.
  /// 
  /// This method is responsible for initializing the SDK with the specified configuration parameters.
  /// - Parameters:
  ///   - arguments: A dictionary containing configuration parameters for the SDK initialization.
  /// - Returns: A `ZettlePluginResponse` object indicating the result of the SDK initialization.
  private func initSDK(arguments: Dictionary<String, Any>) -> ZettlePluginResponse {
      let method = "initialize";
      
      guard !ZettleIosPlugin.isInitialized else {
            print("iZettle SDK is already initialized")
            return ZettlePluginResponse(methodName: method, success: true)
      }
      
      do{
          let authenticationProvider = try iZettleSDKAuthorization(
            clientID: arguments["clientID"] as! String,
            callbackURL: URL(string: arguments["callbackURL"] as! String)!
          )
          
          iZettleSDK.shared().start(with: authenticationProvider)
          ZettleIosPlugin.isInitialized = true
          print("iZettle Initialized");
          return ZettlePluginResponse(methodName: method, success: true);
      }catch{
          print("Failed to initialize iZettle SDK with error: \(error.localizedDescription)")
          return ZettlePluginResponse(methodName: method, success: false, errorMessage: error.localizedDescription);
      }
  }
   
  /// Presents the application settings interface.
  private func showSettings() -> Void{
        iZettleSDK.shared().presentSettings(from: topController())
  }
    
  /// Logs out the current user session.
  private func logout() -> Void{
        iZettleSDK.shared().logout()
  }

}



