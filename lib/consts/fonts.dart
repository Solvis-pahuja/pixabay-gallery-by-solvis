import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'Montserrat';

  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;

  static const TextStyle headline1 = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: primaryFont,
    fontSize: mediumFontSize,
    color: Colors.black,
  );
}
