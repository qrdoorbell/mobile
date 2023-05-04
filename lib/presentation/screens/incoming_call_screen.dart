import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class IncomingCallScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IncomingCallScreenState();
  }
}

class IncomingCallScreenState extends State<IncomingCallScreen> {
  late CallKitParams? calling;

  @override
  Widget build(BuildContext context) {
    final params = jsonDecode(jsonEncode(ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>));
    calling = CallKitParams.fromJson(params);
    debugPrint(calling?.toJson().toString());

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Calling...'),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () async {
                  if (calling != null) {
                    FlutterCallkitIncoming.endCall(calling!.id!);
                    calling = null;
                  }

                  // END CALL HERE
                },
                child: const Text('End Call'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (calling != null) FlutterCallkitIncoming.endCall(calling!.id!);
  }
}
