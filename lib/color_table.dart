import 'package:flutter/material.dart';

// 色管理
class ColorTable {
  static const int _primaryWhiteValue = 0xFFFAFAFA;
  static const MaterialColor primaryWhiteColor = MaterialColor(
    _primaryWhiteValue,
    <int, Color>{
      50: Color(0xFFf2f3f9),
      100: Color(0xFFf2f4f9),
      200: Color(0xFFf2f5f9),
      300: Color(0xFFf2f6f9),
      400: Color(0xFFf2f7f9),
      500: Color(_primaryWhiteValue),
      600: Color(0xFFd7eaed),
      700: Color(0xFFbcdbe0),
      800: Color(0xFFa1cdd4),
      900: Color(0xFF87bec7),
    },
  );

  static const int _primaryBlackValue = 0xFF2B2B2B;
  static const MaterialColor primaryBlackColor = MaterialColor(
    _primaryBlackValue,
    <int, Color>{
      50: Color(0xFFbebebe),
      100: Color(0xFFa1a1a1),
      200: Color(0xFF838383),
      300: Color(0xFF666666),
      400: Color(0xFF484848),
      500: Color(_primaryBlackValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );

  static const int _primaryYellowValue = 0xFFEEE483;
  static const MaterialColor primaryYellowColor = MaterialColor(
    _primaryYellowValue,
    <int, Color>{
      50: Color(0xFF0285d3),
      100: Color(0xFF0279c0),
      200: Color(0xFF026dac),
      300: Color(0xFF016199),
      400: Color(0xFF015485),
      500: Color(_primaryYellowValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );

  static const int _primaryGreenValue = 0xFF7ED477;
  static const MaterialColor primaryGreenColor = MaterialColor(
    _primaryGreenValue,
    <int, Color>{
      100: Color(0xFFeffaee),
      200: Color(0xFFd3f0d0),
      300: Color(0xFFb7e7b3),
      400: Color(0xFF9add95),
      500: Color(_primaryGreenValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );

  static const int _lightGradientBeginValue = 0xFF7DC387;
  static const MaterialColor lightGradientBeginColor = MaterialColor(
    _lightGradientBeginValue,
    <int, Color>{
      50: Color(0xFF0285d3),
      100: Color(0xFF0279c0),
      200: Color(0xFF026dac),
      300: Color(0xFF016199),
      400: Color(0xFF015485),
      500: Color(_lightGradientBeginValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );

  static const int _lightGradientEndValue = 0xFFDBE9EA;
  static const MaterialColor lightGradientEndColor = MaterialColor(
    _lightGradientEndValue,
    <int, Color>{
      50: Color(0xFF9bd9fe),
      100: Color(0xFF61c3fe),
      200: Color(0xFF26adfd),
      300: Color(0xFF0292e7),
      400: Color(0xFF026dac),
      500: Color(_lightGradientEndValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );
}
