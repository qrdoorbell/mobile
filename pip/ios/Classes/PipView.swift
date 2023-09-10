import UIKit
import AVKit
import flutter_webrtc

class PipView: UIView {
    private var localView: UIView = UIView()
    private var rtcRenderer: RTCMTLVideoView? = nil
    private var peerConnectionId: String? = nil
    private var remoteStreamId: String? = nil
    private var isLocalCameraEnable: Bool = false
    private var isRemoteCameraEnable: Bool = false
    private var pictureInPictureIsRunning: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        debugPrint("PipView.setupView: frame=\(frame) bounds=\(bounds) peerConnectionId=\(String(describing: peerConnectionId)) remoteStreamId=\(String(describing: remoteStreamId)) isRemoteCameraEnable=\(isRemoteCameraEnable))")

        localView = UIView()
        localView.clipsToBounds = true

        addSubview(localView)
        localView.translatesAutoresizingMaskIntoConstraints = false
        localView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        localView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        localView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        localView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func initParameters(peerConnectionId: String, remoteStreamId: String, isRemoteCameraEnable: Bool) {
        self.peerConnectionId = peerConnectionId
        self.remoteStreamId = remoteStreamId
        self.isRemoteCameraEnable = isRemoteCameraEnable
    }
    
    func updateStateValue(isRemoteCameraEnable: Bool) {
        if (self.isRemoteCameraEnable != isRemoteCameraEnable) {
            self.isRemoteCameraEnable = isRemoteCameraEnable
            
            if (!self.pictureInPictureIsRunning) {
                return
            }
            
            if (self.isRemoteCameraEnable) {
                self.addRemoteRendererToView()
            } else {
                self.rtcRenderer?.removeFromSuperview()
            }
        }
    }
    
    func configurationLayoutConstraintForRenderer() {
        if (self.rtcRenderer == nil) {
            return
        }
        
        self.rtcRenderer!.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func configurationVideoView() {
        if (remoteStreamId == nil || peerConnectionId == nil) {
            return
        }
        
        if #available(iOS 15.0, *) {
            // Remote
            if (self.isRemoteCameraEnable) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.addRemoteRendererToView()
                }
            }
        }
    }

    func addRemoteRendererToView() {
        self.rtcRenderer = RTCMTLVideoView()
        self.rtcRenderer!.contentMode = .scaleAspectFit
        self.rtcRenderer!.videoContentMode = .scaleAspectFill
        
        let mediaRemoteStream = FlutterWebRTCPlugin().stream(forId: self.remoteStreamId, peerConnectionId: self.peerConnectionId)
        mediaRemoteStream?.videoTracks.first?.add(self.rtcRenderer!)
        
        self.configurationLayoutConstraintForRenderer()
    }
    
    func updateLayoutVideoVideo() {
        self.stopPipView()
        
        self.pictureInPictureIsRunning = true
        self.configurationVideoView()
    }

    func disposeVideoView() {
        remoteStreamId = nil
        peerConnectionId = nil
    }

    func stopPipView() {
        self.pictureInPictureIsRunning = false
        self.rtcRenderer?.removeFromSuperview()
    }
}
