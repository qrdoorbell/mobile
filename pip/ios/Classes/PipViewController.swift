import AVKit
import UIKit
import Flutter
import flutter_webrtc

class PipViewController: FlutterViewController {
    static let shared: PipViewController? = nil

    final var pipVideoCallViewController: AVPictureInPictureVideoCallViewController = AVPictureInPictureVideoCallViewController()

    var pipController: AVPictureInPictureController?
    var pipContentSource: AVPictureInPictureController.ContentSource?
    
    var pipView: PipView = PipView()

    init() {
        super.init(nibName: nil, bundle: nil)
        debugPrint("PipViewController.init")

        if (PipViewController.shared == nil) {
            PipViewController.shared = self
        }
    }

    init(required coder: NSCoder!) {
        super.init(coder: coder)
        debugPrint("PipViewController.init(coder)")

        if (PipViewController.shared == nil) {
            PipViewController.shared = self
        }
    }
    
    open override func viewDidLoad() {
        debugPrint("PipViewController.viewDidLoad")

        addFlutterView(with: (UIApplication.shared.delegate as! FlutterAppDelegate).window.rootViewController as! FlutterViewController)
        
        pipVideoCallViewController.preferredContentSize = CGSize(width: 800, height: 1280)
        pipVideoCallViewController.view.clipsToBounds = true
        
        pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: self.view,
            contentViewController: pipVideoCallViewController
        )
    }
    
    func configurationPictureInPicture(result: @escaping  FlutterResult, peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool) {
        debugPrint("PipViewController.configurationPictureInPicture: peerConnectionId=\(peerConnectionId) remoteStreamId=\(remoteStreamId) isRemoteCameraEnable=\(isRemoteCameraEnable) pipContentSource=\(String(describing: pipContentSource))")

        if (pipContentSource != nil) {
            pipController = AVPictureInPictureController(contentSource: pipContentSource!)
            pipController!.canStartPictureInPictureAutomaticallyFromInline = true
            pipController!.delegate = self
            
            // Add view
            pipView = PipView(frame: pipVideoCallViewController.view.frame)
            pipView.contentMode = .scaleAspectFit
            pipView.initParameters(peerConnectionId: peerConnectionId, remoteStreamId: remoteStreamId, isRemoteCameraEnable: isRemoteCameraEnable)
            
            pipVideoCallViewController.view.addSubview(pipView)
            
            addConstraintLayout()
        }
        
        result(true)
    }
    
    func addConstraintLayout() {
        if #available(iOS 15.0, *) {
            pipView.translatesAutoresizingMaskIntoConstraints = false
            let constraints = [
                pipView.leadingAnchor.constraint(equalTo: pipVideoCallViewController.view.leadingAnchor),
                pipView.trailingAnchor.constraint(equalTo: pipVideoCallViewController.view.trailingAnchor),
                pipView.topAnchor.constraint(equalTo: pipVideoCallViewController.view.topAnchor),
                pipView.bottomAnchor.constraint(equalTo: pipVideoCallViewController.view.bottomAnchor)
            ]
            pipVideoCallViewController.view.addConstraints(constraints)
            pipView.bounds = pipVideoCallViewController.view.frame
        }
    }
    
    func updatePictureInPictureView(_ result: @escaping FlutterResult, isRemoteCameraEnable: Bool) {
        pipView.updateStateValue(isRemoteCameraEnable: isRemoteCameraEnable)
        result(true)
    }
    
    func disposePictureInPicture() {
        pipView.disposeVideoView()
        
        if #available(iOS 15.0, *) {
            pipVideoCallViewController.view.removeAllSubviews()
        }
        
        if (pipController == nil) {
            return
        }
        
        pipController = nil
    }
    
    func stopPictureInPicture() {
        if #available(iOS 15.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.pipController?.stopPictureInPicture()
            }
        }
    }
}

extension PipViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(">> pictureInPictureControllerWillStopPictureInPicture")
        self.pipView.stopPipView()
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print(">> pictureInPictureControllerWillStartPictureInPicture")
        self.pipView.updateLayoutVideoVideo()
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Unable start pip error:", error.localizedDescription)
    }
}


// create an extension for all UIViewControllers
extension UIViewController {
    /**
     Add a flutter sub view to the UIViewController
     sets constraints to edge to edge, covering all components on the screen
     */
    func addFlutterView(with flutterViewController: FlutterViewController) {
        // create the flutter view controller
//        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
      let flutterViewController = FlutterViewController()
        addChild(flutterViewController)
        
        guard let flutterView = flutterViewController.view else { return }
        
        // allows constraint manipulation
        flutterView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(flutterView)
        
        // set the constraints (edge-to-edge) to the flutter view
        let constraints = [
            flutterView.topAnchor.constraint(equalTo: view.topAnchor),
            flutterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            flutterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        // apply (activate) the constraints
        NSLayoutConstraint.activate(constraints)
        
        flutterViewController.didMove(toParent: self)
        
        // updates the view with configured layout
        flutterView.layoutIfNeeded()
    }
}
