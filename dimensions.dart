import 'package:flutter/material.dart';

class Dimensions {
  static const double FONT_XS = 10.0;
  static const double FONT_S = 12.0;
  static const double FONT_M = 14.0;
  static const double FONT_L = 16.0;
  static const double FONT_XL = 18.0;
  static const double FONT_2XL = 24.0;
  static const double FONT_3XL = 26.0;
  static const double FONT_4XL = 28.0;

  static const double PADDING_XS = 5.0;
  static const double PADDING_S = 10.0;
  static const double PADDING_M = 15.0;
  static const double PADDING_L = 20.0;
  static const double PADDING_XL = 25.0;
  static const double PADDING_2XL = 30.0;
  static const double PADDING_3XL = 35.0;
  static const double PADDING_4XL = 40.0;

  static const double RADIUS_S = 5.0;
  static const double RADIUS_M = 10.0;
  static const double RADIUS_L = 15.0;
  static const double RADIUS_XL = 20.0;
  static const double RADIUS_2XL = 25.0;
  static const double RADIUS_3XL = 30.0;
  static const double RADIUS_4XL = 35.0;

  static screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}
