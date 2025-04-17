import 'package:flutter/material.dart';

class ChartLabel extends StatelessWidget {
  final String label;
  final Color color;

  const ChartLabel({Key? key, required this.label, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
