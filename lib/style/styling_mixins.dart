import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/debug.dart';
import 'package:gigya_native_screensets_engine/widgets/components/image.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';

//region ENUMS
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

//endregion

mixin StyleMixin {
  final NssConfig? config = NssIoc().use(NssConfig);

  /// Default style mapping.
  Map<String, dynamic> defaultStyles = {};

  Map<String, dynamic> getDefaultStyles() {
    if (defaultStyles.isEmpty) {
      // Populate default styles map from config styles.
      if (config!.styleLibrary.isNotEmpty) {
        defaultStyles = (config!.styleLibrary["_defaults"]["general"]["style"])
            .cast<String, dynamic>();
      }
    }
    // Need to be casted.
    return defaultStyles;
  }

  /// Default theme mapping.
  final Map<String, dynamic> defaultTheme = {
    'primaryColor': 'blue',
    'secondaryColor': 'white',
    'textColor': 'black',
    'enabledColor': 'blue',
    'disabledColor': 'grey',
    'errorColor': 'red',
  };

  /// Check if the requesting widget contains old "customTheme" property.
  /// This is only viable via the markup code and is considered deprecated.
  /// However, if still present in the code it will take priority (backward compatibility).
  dynamic _widgetDataContainsDeprecatedThemedStyle(
      NssWidgetData? data, Styles style) {
    if (data == null) return null;
    if (config!.markup!.customThemes == null) return null;
    String customTheme = data.theme ?? '';
    if (config!.markup!.customThemes!.containsKey(customTheme)) {
      var value = getStyleValue(style,
          config!.markup!.customThemes![customTheme].cast<String, dynamic>());
      return value;
    }
    return null;
  }

  /// Check if the requesting widget contains a custom theme that is related to the
  /// style library json data.
  dynamic _widgetDataContainsThemedStyle(NssWidgetData? data, Styles style) {
    if (data == null) return null;
    if (config!.styleLibrary.isEmpty) return null;
    String customTheme = data.theme ?? '';
    if (customTheme.isEmpty) return null;
    final String? widgetIdentifier = getWidgetIdentifier(data);
    if (widgetIdentifier == null) return null;
    if (config!.styleLibrary.containsKey(widgetIdentifier)) {
      final Map<dynamic, dynamic> widgetStyleMap =
          config!.styleLibrary[widgetIdentifier];
      if (widgetStyleMap.containsKey(customTheme)) {
        final Map<dynamic, dynamic> styleMap = widgetStyleMap[customTheme];
        var value = styleMap["style"][style.name];
        return value;
      }
    }
    return null;
  }

  /// Check if the requesting widget contains specific style properties via the markup code.
  /// If so, it will take priority and override style library settings.
  dynamic _widgetDataContainsSpecificStyleProperties(
      NssWidgetData? data, Styles style) {
    if (data == null) return null;
    if (data.style == null) return null;
    if (data.style!.isNotEmpty) {
      var dataStyles = data.style;
      if (!dataStyles!.containsKey(style.name)) {
        return null;
      }
      var value = getStyleValue(style, dataStyles);
      return value;
    }
    return null;
  }

  bool isButtonStyleInput(NssWidgetType type) {
    switch (type) {
      case NssWidgetType.submit:
      case NssWidgetType.button:
        return true;
      default:
        return false;
    }
  }

  bool isTextStyleInput(NssWidgetType type) {
    switch (type) {
      case NssWidgetType.emailInput:
      case NssWidgetType.passwordInput:
      case NssWidgetType.textInput:
        return true;
      default:
        return false;
    }
  }

  String? getWidgetIdentifier(NssWidgetData? data) {
    String? widgetIdentifier;
    NssWidgetType? type = data?.type;
    if (type == null) return null;
    if (isButtonStyleInput(type)) {
      type = NssWidgetType.button;
    }
    if (isTextStyleInput(type)) {
      type = NssWidgetType.textInput;
    }
    widgetIdentifier = type.name;
    return widgetIdentifier;
  }

  /// Get the relevant style value.
  dynamic getStyle(
    Styles style, {
    NssWidgetData? data,
    Map<String, dynamic>? styles,
    String? themeProperty,
  }) {
    var value;

    // Handle deprecated markup theme
    value = _widgetDataContainsDeprecatedThemedStyle(data, style);
    if (value != null) {
      return _generateStyleData(style, value);
    }

    // Handle style library themed style.
    value = _widgetDataContainsThemedStyle(data, style);
    if (value != null) {
      return _generateStyleData(style, value);
    }

    // Widget contains specific style attribute. Use it.
    value = _widgetDataContainsSpecificStyleProperties(data, style);
    if (value != null) {
      return _generateStyleData(style, value);
    }

    // Use default (fetched from style library defaults map).
    final String? widgetIdentifier = getWidgetIdentifier(data);
    if (widgetIdentifier != null) {
      value =
          config!.styleLibraryDefaults[widgetIdentifier]['style']?[style.name];
      if (value != null) {
        return _generateStyleData(style, value);
      }
    }

    // No data may be available. Use themed property.
    if (themeProperty != null) {
      value = themeIsNeeded(style, data?.style, themeProperty) ?? value;
      if (value != null) {
        return _generateStyleData(style, value);
      }
    }

    // When all else fails we have a style requested with no data.
    // Apply default style properties.
    value = getDefaultStyles()[style.name];
    return _generateStyleData(style, value);
  }

  /// Generate style given requested value.
  dynamic _generateStyleData(Styles style, value) {
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

//region STYLE LOGIC GETTERS

  /// Get the relevant style value from provided [styles] markup parsed map.
  getStyleValue(Styles style, Map<String, dynamic>? styles) {
    if (styles == null) styles = getDefaultStyles();
    return styles[style.name] ?? getDefaultStyles()[style.name];
  }

  getDefaultStylesValue() {}

  getFallbackStyleValue() {}

  /// Check if to apply a specific theme.a
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
    if (padding is double) {
      return EdgeInsets.all(padding);
    } else if (padding is int) {
      return EdgeInsets.all(ensureDouble(padding)!);
    } else if (padding is List<dynamic>) {
      return EdgeInsets.only(
          left: ensureDouble(padding[0])!,
          top: ensureDouble(padding[1])!,
          right: ensureDouble(padding[2])!,
          bottom: ensureDouble(padding[3])!);
    }
    return EdgeInsets.zero;
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
    if(weight == null) {
      return FontWeight.w400;
    }
    else{
      try{
        int? val = int.tryParse(weight.toString());
        if(val != null)
          return FontWeight.values[val- 1];
        else{
          switch (weight) {
            case 'bold':
              return FontWeight.bold;
            default:
              return FontWeight.w400;
          }
        }
      }
      catch(e) {
        return FontWeight.w400;
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
    return a.getValue ?? TextAlign.start;
  }

  convertToDirectionalAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.start:
        return AlignmentDirectional.centerStart;
      case TextAlign.end:
        return AlignmentDirectional.centerEnd;
      case TextAlign.center:
        return AlignmentDirectional.center;
      default:
        return AlignmentDirectional.centerStart;
      // none
    }
  }

//endregion

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

  TextStyle styleText(data) {
    final Color? color =
        getStyle(Styles.fontColor, data: data, themeProperty: 'textColor');

    return TextStyle(
      color: data!.disabled! ? color!.withOpacity(0.1) : color,
      fontSize: getStyle(Styles.fontSize, data: data),
      fontWeight: getStyle(Styles.fontWeight, data: data),
    );
  }

  TextStyle styleCupertinoPlaceholder(data) {
    return TextStyle(
      color: data!.disabled! ? Colors.black12.withOpacity(0.1) : Colors.black45,
      fontSize: getStyle(Styles.fontSize, data: data),
      fontWeight: getStyle(Styles.fontWeight, data: data),
    );
  }
//endregion
}
