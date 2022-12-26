import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/styles.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

/// Custom type mixin class for DatePickerWidget.
/// Used to distinguish the top level styling of the input trigger to the picker dialog.
mixin DatePickerStyleMixin on StyleMixin {
  /// Specific styling for picker background.
  Color getPickerBackground(DatePickerStyle? style, themeProperty) {
    if (style != null && style.primaryColor!.isNotEmpty) {
      return getColor(style.primaryColor!) ?? Colors.white;
    } else if (themeProperty != null) {
      if (config!.markup!.theme != null) {
        return getThemeColor(themeProperty);
      }
    }
    // Static fallback is white.
    return Colors.white;
  }

  /// Specific styling for picker font color.
  Color getPickerLabelColor(DatePickerStyle? style, themeProperty) {
    if (style != null && style.labelColor!.isNotEmpty) {
      return getColor(style.labelColor!) ?? Colors.black;
    } else if (themeProperty != null) {
      if (config!.markup!.theme != null) {
        return getThemeColor(themeProperty);
      }
    }
    // Static fallback is black.
    return Colors.black;
  }
}
