import Flutter
import UIKit

public class PipPlugin: NSObject, FlutterPlugin {
  public static let CHANNEL_NAME = "io.qrdoorbell.app/pip"

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    debugPrint("PipPlugin.handle: method=\(call.method) arguments=\(String(describing: call.arguments))")

    switch call.method {
    case "createPiP":
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        let remoteStreamId = arguments["remoteStreamId"] as? String ?? ""
        let peerConnectionId = arguments["peerConnectionId"] as? String ?? ""
        let isRemoteCameraEnable = arguments["isRemoteCameraEnable"] as? Bool ?? false

        PipViewController.shared!.configurationPictureInPicture(
            result: result,
            peerConnectionId: peerConnectionId,
            remoteStreamId: remoteStreamId,
            isRemoteCameraEnable: isRemoteCameraEnable
        )
        
        result(true)
        break
    case "disposePiP":
        PipViewController.shared!.disposePictureInPicture()
        
        result(true)
        break
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    debugPrint("PipPlugin.registering: registrar=\(registrar)")

    let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
    let instance = PipPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    debugPrint("PipPlugin.registered: registrar=\(registrar) channel=\(channel) instance=\(instance)")
  }
}
