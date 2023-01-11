import 'package:flutter/painting.dart';

class CommonCSS {

  static buttonDecoration(bool isEnable, double borderRadius, int color, double opacity, int secondColor) {
    if(secondColor != 0) {
      return BoxDecoration(
          color: isEnable == true ? Color(color) : Color(secondColor).withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius));
    } else {
      return BoxDecoration(
          color: isEnable == true ? Color(color) : Color(color).withOpacity(0.5),
          borderRadius: BorderRadius.circular(borderRadius));
    }
  }
}
