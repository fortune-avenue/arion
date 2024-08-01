import 'package:flutter/material.dart';

class AppTheme {
  static const subText = TextStyle(
    fontFamily: 'Pixelify',
    fontWeight: FontWeight.w500,
    fontSize: 10,
    color: Colors.white,
  );
  static const text = TextStyle(
    fontFamily: 'Pixelify',
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: Colors.white,
  );
  static const headline3 = TextStyle(
    fontFamily: 'Pixelify',
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
  static final headline2 = TextStyle(
    fontFamily: 'Pixelify',
    fontWeight: FontWeight.w500,
    fontSize: 28,
    color: Colors.brown.shade900,
  );
  static const headline1 = TextStyle(
    fontSize: 72,
    fontFamily: 'Pixelify',
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

extension XTextStyle on TextStyle {
  TextStyle get white => copyWith(color: Colors.white);
}
