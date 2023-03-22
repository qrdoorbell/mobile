import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrdoorbell_mobile/routing.dart';

class QRCodeScreen extends StatelessWidget {
  final String doorbellId;

  const QRCodeScreen(this.doorbellId);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: () => RouteStateScope.of(context).go('/doorbells/$doorbellId'),
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Column(children: [
                  Title(color: Colors.black, child: Text(doorbellId)),
                  Image.network(
                    'https://api.qrdoorbell.io/api/v1/qr/$doorbellId',
                    // loadingBuilder: (context, child, loadingProgress) => const Center(child: Text("Loading...")),
                  ),
                ]))));
  }
}
