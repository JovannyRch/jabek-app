import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        children: [
            Image.asset('assets/images/logo.jpeg',height: 210.0),
        ],
      ),
    );
  }
}
