import "package:flutter/material.dart";

class CommonAppBar extends StatelessWidget {
  final Widget? action;
  final Widget? leftAction;
  final String? title;
  final String? subtitle;

  const CommonAppBar({
    this.action,
    this.leftAction,
    this.title,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Container(
        // height: AppTheme.appBarSize,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 1.0),
            )
          ],
        ),
        child: Row(
          children: <Widget>[
            Visibility(
              visible: leftAction == null,
              replacement: leftAction ?? SizedBox.shrink(),
              child: SizedBox(
                width: 100.0, // Minimum size of a flat button
                child: TextButton(
                    child: Text(
                      "Back",
                      // style: TextButtonTheme,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    // style: subtitle == null ? AppTheme.appBarTitleTextStyle : AppTheme.appBarTitle2TextStyle,
                  ),
                  Visibility(
                    visible: subtitle != null,
                    child: Text(
                      subtitle ?? "",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      // style: AppTheme.appBarSubtitleTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
