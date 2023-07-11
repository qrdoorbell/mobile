import 'package:flutter/cupertino.dart';

import '../../data.dart';
import '../../services/call_manager.dart';

class CallManagerBanner extends StatefulWidget {
  @override
  State<CallManagerBanner> createState() => _CallManagerBannerState();
}

class _CallManagerBannerState extends State<CallManagerBanner> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CallInfo>(
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data == null) return Container();
          if (snapshot.data!.callState == CallEventType.end) return Container();

          return Container(
              color: CupertinoColors.systemRed,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    const Icon(CupertinoIcons.phone_fill, color: CupertinoColors.white),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("'${DataStore.of(context).getDoorbellById(snapshot.data!.doorbellId)?.name}' call is in progress",
                          style: const TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
                      Text(snapshot.data!.callState, style: const TextStyle(color: CupertinoColors.white)),
                    ])),
                    CupertinoButton(onPressed: () {}, child: const Text('Join'))
                  ])));
        },
        stream: CallManager().callInfoStream);
  }
}
