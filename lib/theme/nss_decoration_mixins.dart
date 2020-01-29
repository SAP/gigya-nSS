import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// General widget decoration mixin.
/// Includes useful UI builders that correspond with the applied markup.
class NssWidgetDecorationMixin {
  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double ensureDouble(num) {
    return (num is int) ? num.toDouble() : num;
  }

  /// parse padding value.
  /// Optional input can be a double, integer or a number array (left, right, top, bottom).
  EdgeInsetsGeometry withPadding(padding) {
    if (padding is double) {
      return EdgeInsets.all(padding);
    } else if (padding is int) {
      return EdgeInsets.all(padding.toDouble());
    } else if (padding is List<dynamic>) {
      return EdgeInsets.only(
          left: ensureDouble(padding[0]),
          right: ensureDouble(padding[1]),
          top: ensureDouble(padding[2]),
          bottom: ensureDouble(padding[3]));
    }
    return EdgeInsets.all(0);
  }

  //region Colors

  Color parseColor(String color, {bool platformAware}) {
    if (_isHexColor(color))
      return _parseHexColor(color);
    else {
      return getColorBy(color, platformAware: platformAware ?? false);
    }
  }

  bool _isHexColor(String color) {
    return (color.contains("#"));
  }

  Color _parseHexColor(String hexColorString) {
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

//endregion
}

/// Input field decoration classes mixin.
/// Support for both [TextField] & [CupertinoTextField].
class NssInputDecorationMixin with NssWidgetDecorationMixin {}
