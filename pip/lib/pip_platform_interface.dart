import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pip_method_channel.dart';

abstract class PipPlatform extends PlatformInterface {
  PipPlatform() : super(token: _token);

  static final Object _token = Object();

  static PipPlatform _instance = PipMethodChannel();

  /// The default instance of [PipPlatform] to use.
  ///
  /// Defaults to [PipMethodChannel].
  static PipPlatform get instance => _instance;

  static set instance(PipPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> createPipVideoCall(
      {required String remoteStreamId, required String peerConnectionId, bool isRemoteCameraEnable = true}) async {
    throw UnimplementedError('createPipVideoCall() has not been implemented.');
  }

  Future<void> disposePiP() async {
    throw UnimplementedError('disposePiP() has not been implemented.');
  }
}
