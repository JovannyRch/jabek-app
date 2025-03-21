import 'package:flutter/material.dart';

class TitleBold extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const TitleBold({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class TitleNormal extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const TitleNormal({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }
}

class TitleLight extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const TitleLight({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: color,
      ),
    );
  }
}

class SubtitleBold extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const SubtitleBold({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class SubtitleNormal extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const SubtitleNormal({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }
}

class SubtitleLight extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const SubtitleLight({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: color,
      ),
    );
  }
}

class BodyTextBold extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const BodyTextBold({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class BodyTextNormal extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const BodyTextNormal({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }
}

class BodyTextLight extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  const BodyTextLight({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: color,
      ),
    );
  }
}
