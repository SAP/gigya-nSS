import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// General widget decoration mixin.
/// Includes useful UI builders that correspond with the applied markup.
class WidgetGeneralDecorationMixin {
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
}

/// Input field decoration classes mixin.
/// Support for both [TextField] & [CupertinoTextField].
class InputDecorationMixin with WidgetGeneralDecorationMixin {}

