import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class UserAccountAvatar extends StatelessWidget {
  final double? size;
  final String name;

  const UserAccountAvatar({super.key, required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserAvatar(
          size: size,
        ),
        Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
      ],
    );
  }
}
