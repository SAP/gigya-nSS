import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/widgets/material/image.dart';

/// Supported styles enum.
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
  indicatorColor,
  textAlign,
  linkColor,
  placeholderColor,
}

extension StylesExt on Styles {
  String get name => describeEnum(this);
}

/// Supported text alignment enum.
enum NssTextAlign { start, end, center, none }

extension NssTextAlignExt on NssTextAlign {
  TextAlign? get getValue {
    switch (this) {
      case NssTextAlign.start:
        return TextAlign.start;
      case NssTextAlign.end:
        return TextAlign.end;
      case NssTextAlign.center:
        return TextAlign.center;
      default:
        return null; // none
    }
  }
}

extension NssMainAlign on TextAlign {
  MainAxisAlignment get getMainAlign {
    switch (this) {
      case TextAlign.start:
        return MainAxisAlignment.start;
      case TextAlign.end:
        return MainAxisAlignment.end;
      case TextAlign.center:
        return MainAxisAlignment.center;
      default:
        return MainAxisAlignment.start; // none
    }
  }
}

mixin StyleMixin {
  final NssConfig? config = NssIoc().use(NssConfig);

  /// Default style mapping.
  final Map<String, dynamic> defaultStyle = {
    'margin': 0,
    'fontSize': 14,
    'fontColor': 'black',
    'fontWeight': 4,
    'background': 'white',
    'elevation': 0,
    'opacity': 1.0,
    'borderColor': '0x8A000000',
    'borderSize': 1,
    'cornerRadius': 8,
    'linkColor': 'blue',
    'placeholderColor': 'black'
  };

  /// Default theme mapping.
  final Map<String, dynamic> defaultTheme = {
    'primaryColor': 'blue',
    'secondaryColor': 'white',
    'textColor': 'black',
    'enabledColor': 'blue',
    'disabledColor': 'grey',
    'errorColor': 'red',
  };

  /// Get the relevant style value.
  dynamic getStyle(
    Styles style, {
    NssWidgetData? data,
    Map<String, dynamic>? styles,
    String? themeProperty,
  }) {
    var value;
    var dataStyles = data != null ? data.style : styles;
    if (data != null) {
      // Check for custom theme first.
      String customTheme = data.theme ?? '';
      if (customTheme.isAvailable() &&
          config!.markup!.theme != null &&
          config!.markup!.customThemes != null &&
          config!.markup!.customThemes!.containsKey(customTheme)) {
        if (config!.markup!.customThemes![customTheme]
            .containsKey(style.name)) {
          value = getStyleValue(
              style,
              config!.markup!.customThemes![customTheme]
                  .cast<String, dynamic>());
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
      case Styles.indicatorColor:
      case Styles.linkColor:
      case Styles.placeholderColor:
        var platformAware = config!.isPlatformAware ?? false;
        return getColor(value, platformAware: platformAware);
      case Styles.fontWeight:
        return getFontWeight(value);
      case Styles.background:
        var platformAware = config!.isPlatformAware ?? false;
        return getBackground(value, platformAware: platformAware);
      case Styles.textAlign:
        return getTextAlign(value);
      default:
        break;
    }
  }

  /// Get the relevant style value from provided [styles] markup parsed map.
  getStyleValue(Styles style, Map<String, dynamic>? styles) {
    if (styles == null) styles = defaultStyle;
    return styles[style.name] ?? defaultStyle[style.name];
  }

  /// Check if to apply a specific theme.
  themeIsNeeded(Styles style, Map<String, dynamic>? styles, String key) {
    if (styles == null) styles = {};
    if (styles[style.name] == null && config!.markup!.theme != null) {
      final theme = config!.markup!.theme![key] ?? defaultTheme[key];
      return theme;
    } else {
      return null;
    }
  }

  /// Get the theme color according to provided theme specific [key].
  Color getThemeColor(String key) {
    if (config!.markup!.theme == null || config!.markup!.theme![key] == null)
      return getColor(defaultTheme[key]) ?? Colors.black;
    else {
      return getColor(config!.markup!.theme![key]) ?? Colors.black;
    }
  }

  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double? ensureDouble(num) => (num is int) ? num.toDouble() : num;

  /// parse padding value.
  /// Optional input can be a double, integer or a number array (left, right, top, bottom).
  EdgeInsetsGeometry getPadding(padding) {
    var result;
    if (padding is double) {
      result = EdgeInsets.all(padding);
    } else if (padding is int) {
      result =  EdgeInsets.all(ensureDouble(padding)!);
    } else if (padding is List<dynamic>) {
      result =  EdgeInsets.fromLTRB(
          ensureDouble(padding[0])!,
          ensureDouble(padding[1])!,
          ensureDouble(padding[2])!,
          ensureDouble(padding[3])!);

      // return EdgeInsets.only(
      //     left: ensureDouble(padding[0])!,
      //     top: ensureDouble(padding[1])!,
      //     right: ensureDouble(padding[2])!,
      //     bottom: ensureDouble(padding[3])!);
    }else {
      result = EdgeInsets.zero;
    }
    print(result);
    return result;
  }

  /// Request a [Color] instance given an multi optional identifier (named, hex).
  Color? getColor(String color, {bool? platformAware}) {
    if (color.contains("#"))
      return _getHexColor(color);
    else {
      return _getColorWithName(color, platformAware: platformAware ?? false);
    }
  }

  /// Get a [Color] instance after parsing the a color hex string.
  /// and [opacity] optional value is available using common opacity two letter pattern.
  Color? _getHexColor(String? hexColorString, {String? opacity}) {
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
  Color _getColorWithName(name, {bool? platformAware}) {
    switch (name) {
      case 'blue':
        return platformAware! ? CupertinoColors.systemBlue : Colors.blue;
      case 'red':
        return platformAware! ? CupertinoColors.systemRed : Colors.red;
      case 'green':
        return platformAware! ? CupertinoColors.systemGreen : Colors.green;
      case 'grey':
        return platformAware! ? CupertinoColors.inactiveGray : Colors.grey;
      case 'yellow':
        return platformAware! ? CupertinoColors.systemYellow : Colors.yellow;
      case 'orange':
        return platformAware! ? CupertinoColors.systemOrange : Colors.orange;
      case 'white':
        return platformAware! ? CupertinoColors.white : Colors.white;
      case 'transparent':
        return platformAware! ? Colors.transparent : Colors.transparent;
      case 'black':
        return platformAware! ? CupertinoColors.black : Colors.black;
      default:
        return platformAware! ? CupertinoColors.black : Colors.black;
    }
  }

  /// Get the requested font weight.
  /// Available options:
  ///  - 'bold', 'thin' identifiers.
  ///  - number.
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

  /// Get the relevant background widget.
  /// Available options:
  ///  - Remote image given URL.
  ///  - Color (Hex or name by default).
  getBackground(background, {bool? platformAware}) {
    if (background.contains("#"))
      return _getHexColor(background);
    else if (background.contains("http://") ||
        background.contains("https://")) {
      return NetworkImage(background);
    } else if (background.substring(0, 1) == "/") {
      var data = NssWidgetData.fromJson({"url": background.substring(2)});
      return ImageWidget(key: UniqueKey(), data: data);
    } else {
      return _getColorWithName(background,
          platformAware: platformAware ?? false);
    }
  }

  getTextAlign(align) {
    align = "NssTextAlign.$align";
    NssTextAlign a = NssTextAlign.values.firstWhere(
        (f) => f.toString() == align,
        orElse: () => NssTextAlign.none);
    return a.getValue;
  }

  //region SIMPLIFIED STYLE GETTERS

  dynamic styleBackground(data) => getStyle(Styles.background, data: data);

  Color? styleFontColor(data, disabled) => disabled
      ? getStyle(Styles.fontColor, data: data, themeProperty: 'disabledColor')
          .withOpacity(0.3)
      : getStyle(Styles.fontColor, data: data, themeProperty: 'textColor');

  dynamic styleFontSize(data) => getStyle(Styles.fontSize, data: data);

  dynamic styleFontWeight(data) => getStyle(Styles.fontWeight, data: data);

  dynamic styleBorderSize(data) => getStyle(Styles.borderSize, data: data);

  dynamic styleBorderRadius(data) => getStyle(Styles.cornerRadius, data: data);

  dynamic styleBorderColor(data) =>
      getStyle(Styles.borderColor, data: data, themeProperty: "disabledColor");

  TextAlign styleTextAlign(data) =>
      getStyle(Styles.textAlign, data: data) ?? TextAlign.start;

  dynamic styleOpacity(data) => getStyle(Styles.opacity, data: data);

  dynamic stylePadding(data) => getStyle(Styles.margin, data: data);

  dynamic stylePlaceholder(data, bool disabled) => disabled
      ? getStyle(Styles.placeholderColor,
              data: data, themeProperty: 'disabledColor')
          .withOpacity(0.3)
      : getStyle(Styles.placeholderColor,
              data: data, themeProperty: 'textColor')
          .withOpacity(0.5);

//endregion
}
