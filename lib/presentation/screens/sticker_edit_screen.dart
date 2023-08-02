import 'package:flutter/cupertino.dart';

import '../../routing/route_state.dart';
import '../controls/stickers/sticker_v1_horizontal.dart';
import '../controls/stickers/sticker_v1_vertical.dart';

class StickerEditScreen extends StatelessWidget {
  final String doorbellId;
  final String stickerTemplateId;

  const StickerEditScreen({super.key, required this.doorbellId, required this.stickerTemplateId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoColors.white,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 10),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId'),
            color: CupertinoColors.activeBlue,
          ),
        ),
        child: getStickerControlByTemplateId(stickerTemplateId));
  }

  static Widget getStickerControlByTemplateId(String stickerTemplateId) {
    switch (stickerTemplateId) {
      case 'v1_vertical':
        return StickerV1Vertical();
      case 'v1_horizontal':
        return StickerV1Horizontal();
      default:
        return StickerV1Vertical();
    }
  }
}
