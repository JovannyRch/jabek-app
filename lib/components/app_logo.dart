import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        children: [
          /*   Image.asset('assets/logo.png', width: 100.0, height: 100.0), */
          Placeholder(fallbackHeight: 100.0, fallbackWidth: 100.0),
          SizedBox(height: 16.0),
          Text(
            'JEBEK',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
