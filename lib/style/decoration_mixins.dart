import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

/// General widget decoration mixin.
/// Includes useful UI builders that correspond with the applied markup.
mixin WidgetDecorationMixin {
  final NssConfig config = NssIoc().use(NssConfig);

  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double ensureDouble(num) => (num is int) ? num.toDouble() : num;

  /// parse padding value.
  /// Optional input can be a double, integer or a number array (left, right, top, bottom).
  EdgeInsetsGeometry withPadding(padding) {
    if (padding is double) {
      return EdgeInsets.all(padding);
    } else if (padding is int) {
      return EdgeInsets.all(ensureDouble(padding));
    } else if (padding is List<dynamic>) {
      return EdgeInsets.only(
          left: ensureDouble(padding[0]),
          top: ensureDouble(padding[1]),
          right: ensureDouble(padding[2]),
          bottom: ensureDouble(padding[3]));
    }
    return EdgeInsets.zero;
  }

  /// Use as a default padding value for all widgets that dd not contain a padding style parameter.
  defaultPadding() => withPadding(12);

  /// Request a [Color] instance given an multi optional identifier (named, hex).
  Color getColor(String color, {bool platformAware}) {
    if (color.contains("#"))
      return _getColorWithHex(color);
    else {
      return _getColorWithName(color, platformAware: platformAware ?? false);
    }
  }

  /// Get a [Color] instance after parsing the a color hex string.
  /// and [opacity] optional value is available using common opacity two letter pattern.
  Color _getColorWithHex(String hexColorString, {String opacity}) {
    if (hexColorString == null) {
      return null;
    }
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "");
    if (hexColorString.length == 6) {
      hexColorString = (opacity ?? "FF") + hexColorString;
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }

  /// Get a [Color] instance given color name.
  /// Method is platform aware.
  //TODO: Need to research relevant colors used with Apple's cupertino pattern.
  Color _getColorWithName(name, {bool platformAware}) {
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

  /// Determine if this widget should be nested within an [Expanded] widget.
  Widget expandIfNeeded(NssWidgetData data, Widget child) {
    return data.expand ? Expanded(child: child) : Flexible(child: child);
  }

  Widget sizeIfNeeded(NssWidgetData data, Widget child) {
    if (data.style == null) data.style = {};
    var size = data.style['size'];
    // Check for size parameter in available custom theme. Override current if exists.
    String customTheme = data.theme;
    if (customTheme != null && config.markup.theme.containsKey(customTheme)) {
      Map<String, dynamic> themeMap = config.markup.theme[customTheme];
      if (themeMap.containsKey('size')) {
        size = themeMap['size'];
      }
    }
    if (size == null) {
      return child;
    }
    return SizedBox(
      width: ensureDouble(size[0]),
      height: ensureDouble(size[1]),
      child: child,
    );
  }
}

/// Input field decoration classes mixin.
/// Support for both [TextField] & [CupertinoTextField].
class InputDecorationMixin with WidgetDecorationMixin {}
