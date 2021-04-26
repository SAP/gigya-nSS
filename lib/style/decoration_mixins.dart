import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

/// General widget decoration mixin.
/// Includes useful UI builders that correspond with the applied markup.
mixin DecorationMixin {
  final NssConfig config = NssIoc().use(NssConfig);

  bool isVisible(viewModel, showIf) {
    String result = viewModel.expressions[showIf] ?? 'true';
    return result.toLowerCase() == 'true';
  }
}

/// Apply a specific size to the selected element.
/// Will check the [data] for any "size" property and apply it accordingly.
class NssCustomSizeWidget extends StatelessWidget {
  final NssWidgetData data;
  final Widget child;

  const NssCustomSizeWidget({Key key, this.data, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NssConfig config = NssIoc().use(NssConfig);

    var size;
    // Check for size parameter in available custom theme. Override current if exists.
    final String customTheme = data.theme ?? '';
    // Check if this widget has a size attached in attached custom theme.
    if (customTheme != null && config.markup.customThemes != null && config.markup.customThemes.containsKey(customTheme)) {
      if (config.markup.customThemes[customTheme].containsKey('size')) {
        size = config.markup.customThemes[customTheme]['size'];
      }
    }

    // Explicit size declaration will always get priority over custom theme declaration.
    if (data.style == null) data.style = {};
    if (data.style.containsKey('size')) {
      size = data.style['size'];
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

  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double ensureDouble(num) => (num is int) ? num.toDouble() : num;
}
