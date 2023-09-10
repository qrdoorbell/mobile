import 'pip_platform_interface.dart';

class Pip {
  Pip._internal();

  static Future<void> createPipVideoCall({
    required String remoteStreamId,
    required String peerConnectionId,
    bool isRemoteCameraEnable = true,
  }) async {
    await PipPlatform.instance.createPipVideoCall(
      remoteStreamId: remoteStreamId,
      peerConnectionId: peerConnectionId,
      isRemoteCameraEnable: isRemoteCameraEnable,
    );
  }

  static Future<void> disposePiP() async {
    await PipPlatform.instance.disposePiP();
  }
}
