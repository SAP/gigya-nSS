import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DecorUtils {
  Color parseColor(String color, {bool platformAware}) {
    if (isHexColor(color))
      return parseColor(color);
    else {
      return getColorBy(color, platformAware: platformAware ?? false);
    }
  }

  bool isHexColor(String color) {
    return (color.contains("#"));
  }

  Color parseHexColor(String hexColorString) {
    if (hexColorString == null) {
      return null;
    }
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = "FF" + hexColorString;
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }

  Color getColorBy(name, {bool platformAware}) {
    switch (name) {
      case 'blue':
        return platformAware ? CupertinoColors.systemBlue : Colors.blue;
      case 'red':
        return platformAware ? CupertinoColors.systemRed : Colors.red;
      case 'green':
        return platformAware ? CupertinoColors.systemGreen : Colors.green;
      case 'grey':
        return platformAware ? CupertinoColors.inactiveGray : Colors.grey;
      case 'yellow':
        return platformAware ? CupertinoColors.systemYellow : Colors.yellow;
      case 'orange':
        return platformAware ? CupertinoColors.systemOrange : Colors.orange;
      case 'white':
        return platformAware ? CupertinoColors.white : Colors.white;
      default:
        return platformAware ? CupertinoColors.black : Colors.black;
    }
  }
}
