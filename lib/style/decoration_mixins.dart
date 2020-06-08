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

  /// Determine if this widget should be nested within an [Expanded] widget.
  Widget expandIfNeeded(NssWidgetData data, Widget child) {
    return data.expand ? Expanded(child: child) : Flexible(child: child);
  }

  Widget sizeIfNeeded(NssWidgetData data, Widget child) {
    if (data.style == null) data.style = {};
    var size = data.style['size'];
    // Check for size parameter in available custom theme. Override current if exists.
    final String customTheme = data.theme;
    if (customTheme != null && config.markup.theme.containsKey(customTheme)) {
      Map<dynamic, dynamic> themeMap = config.markup.theme[customTheme];
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
