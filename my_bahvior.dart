import 'package:flutter/material.dart';



// *-*-*-*-*-*-*-*-*-*-*-*-*-*-*- THIS IS CLASS WORKING HIDE TO SCROLL GLOW *-*-*-*-*-*-*-*--*-*-*--*-*-*-*-*-*

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}