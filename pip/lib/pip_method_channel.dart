import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pip_platform_interface.dart';

class PipMethodChannel extends PipPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('io.qrdoorbell.app/pip');

  @override
  Future<void> createPipVideoCall(
      {required String remoteStreamId, required String peerConnectionId, bool isRemoteCameraEnable = true}) async {
    if (!Platform.isIOS) return;

    methodChannel.invokeMethod("createPiP", {
      "remoteStreamId": remoteStreamId,
      "peerConnectionId": peerConnectionId,
      "isRemoteCameraEnable": isRemoteCameraEnable,
    });
  }

  @override
  Future<void> disposePiP() async {
    await methodChannel.invokeMethod("disposePiP");
  }
}
