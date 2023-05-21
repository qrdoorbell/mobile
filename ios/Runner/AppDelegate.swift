import UIKit
import Flutter
import PushKit
import flutter_callkeep

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print(deviceToken)
        //Save deviceToken to your server
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenFor")
        SwiftCallKeepPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("didReceiveIncomingPushWith \(type): \(payload)")
        guard type == .voIP else { return }

        let id = payload.dictionaryPayload["id"] as? String ?? ""
        let callerName = payload.dictionaryPayload["callerName"] as? String ?? ""
        let userId = payload.dictionaryPayload["callerId"] as? String ?? ""
        let handle = payload.dictionaryPayload["handle"] as? String ?? ""
        let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false
        let doorbellId = payload.dictionaryPayload["doorbellId"] as? String ?? ""
        let callToken = payload.dictionaryPayload["callToken"] as? String ?? ""
        
        let data = flutter_callkeep.Data(id: id, callerName: callerName, handle: handle, hasVideo: isVideo)
        data.appName = "QR Doorbell"
        data.iconName = "CallKitLogo"
        data.extra = ["userId": userId, "platform": "ios", "callToken": callToken, "doorbellId": doorbellId]

//        payload.dictionaryPayload.forEach { (key: AnyHashable, value: Any) in
//            data.extra.setValue(value, forKey: key.base as! String)
//        }

        SwiftCallKeepPlugin.sharedInstance?.displayIncomingCall(data, fromPushKit: true)
    }
}
