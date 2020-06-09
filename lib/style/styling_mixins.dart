import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

mixin StyleMixin {
  final NssConfig config = NssIoc().use(NssConfig);

  final Map<String, dynamic> defaultStyle = {
    'margin': 16,
    'fontSize': 14,
    'fontColor': 'black',
    'fontWeight': 4,
    'background': 'transparent',
    'elevation': 3,
    'opacity': 1.0,
    'borderColor': '#000000',
    'borderSize': 1,
    'cornerRadius': 0,
  };

  dynamic getStyle(
    Styles style, {
    NssWidgetData data,
    Map<String, dynamic> styles,
    String themeProperty,
  }) {
    var value;
    var dataStyles = data != null ? data.style : styles;
    if (data != null) {
      // Check for custom theme first.
      String customTheme = data.theme;
      if (customTheme.isAvailable() && config.markup.theme.containsKey(customTheme)) {
        if (config.markup.theme[customTheme].containsKey(style.name)) {
          value = getStyleValue(style, config.markup.theme[customTheme].cast<String, dynamic>());
        }
      }
    }
    if (value == null) {
      // Custom theme not applied. Apply style value or default themed value.
      value = getStyleValue(style, dataStyles);
      if (themeProperty != null) {
        value = themeIsNeeded(style, dataStyles, themeProperty) ?? value;
      }
    }

    switch (style) {
      case Styles.margin:
        return getPadding(value);
      case Styles.fontSize:
      case Styles.elevation:
      case Styles.opacity:
      case Styles.borderSize:
      case Styles.cornerRadius:
        return ensureDouble(value);
      case Styles.borderColor:
      case Styles.fontColor:
        var platformAware = config.isPlatformAware ?? false;
        return getColor(value, platformAware: platformAware);
      case Styles.fontWeight:
        return getFontWeight(value);
      case Styles.background:
        var platformAware = config.isPlatformAware ?? false;
        return getBackground(value, platformAware: platformAware);
      default:
        break;
    }
  }

  getStyleValue(Styles style, Map<String, dynamic> styles) {
    if (styles == null) styles = defaultStyle;
    return styles[style.name] ?? defaultStyle[style.name];
  }

  themeIsNeeded(Styles style, Map<String, dynamic> styles, String key) {
    if (styles == null) styles = {};
    return (styles[style.name] == null && config.markup.theme != null) ? config.markup.theme[key] : null;
  }

  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double ensureDouble(num) => (num is int) ? num.toDouble() : num;

  /// parse padding value.
  /// Optional input can be a double, integer or a number array (left, right, top, bottom).
  EdgeInsetsGeometry getPadding(padding) {
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
      case 'transparent':
        return platformAware ? Colors.transparent : Colors.transparent;
      default:
        return platformAware ? CupertinoColors.black : Colors.black;
    }
  }

  getFontWeight(weight) {
    if (weight is int) {
      return FontWeight.values[weight - 1];
    } else if (weight is String) {
      switch (weight) {
        case 'bold':
          return FontWeight.bold;
        case 'thin':
          return FontWeight.w200;
      }
    }
  }

  getBackground(background, {bool platformAware}) {
    if (background.contains("#"))
      return _getColorWithHex(background);
    else if (background.contains("http://") || background.contains("https://")) {
      return NetworkImage(background);
    } else {
      return _getColorWithName(background, platformAware: platformAware ?? false);
    }
  }

}

enum Styles {
  margin,
  fontColor,
  fontSize,
  fontWeight,
  background,
  cornerRadius,
  borderColor,
  borderSize,
  opacity,
  elevation,
}

extension StylesExt on Styles {
  String get name => describeEnum(this);
}
