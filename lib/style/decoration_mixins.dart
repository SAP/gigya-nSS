import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';

/// General widget decoration mixin.
/// Includes useful UI builders that correspond with the applied markup.
mixin DecorationMixin {
  final NssConfig? config = NssIoc().use(NssConfig);

  /// Check widget visible state [showIf] by evaluating the JS expression provided.
  /// The expression will be evaluated via a native call using each platform JS expression
  /// task.
  bool isVisible(ScreenViewModel viewModel, NssWidgetData? data) {
    if (kIsWeb) return true;
    if (data == null) return true;
    if (data.showIf != null && viewModel.expressions != null) {
      engineLogger!.d('isVisible check for bind: ${data.bind} & showIf: ${data.showIf} & is ${viewModel.expressions![data.showIf]}');
      String result = viewModel.expressions![data.showIf] ?? 'false';
      return result.toLowerCase() == 'true';
    }
    return true;
  }

  /// [Flex] Widgets such as [Column] and [Row] require alignment property in order
  /// to better understand where their child widgets are will layout.
  MainAxisAlignment getMainAxisAlignment(NssAlignment? alignment) {
    if (alignment == null) return MainAxisAlignment.start;
    switch (alignment) {
      case NssAlignment.start:
        return MainAxisAlignment.start;
      case NssAlignment.end:
        return MainAxisAlignment.end;
      case NssAlignment.center:
        return MainAxisAlignment.center;
      case NssAlignment.equal_spacing:
        return MainAxisAlignment.spaceEvenly;
      case NssAlignment.spread:
        return MainAxisAlignment.spaceBetween;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment getCrossAxisAlignment(NssAlignment? alignment) {
    if (alignment == null) return CrossAxisAlignment.center;
    switch (alignment) {
      case NssAlignment.start:
        return CrossAxisAlignment.start;
      case NssAlignment.end:
        return CrossAxisAlignment.end;
      case NssAlignment.center:
        return CrossAxisAlignment.center;
      default:
        return CrossAxisAlignment.center;
    }
  }

  bool isMaterial(context){
    return _getPlatformStyle(context) == PlatformStyle.Material;
  }

  PlatformStyle _getPlatformStyle(context){
    TargetPlatform? devicePlatform =  defaultTargetPlatform;
    PlatformStyleData? designStyle = PlatformProvider.of(context)?.settings.platformStyle;

    PlatformStyle? result = PlatformStyle.Material;
    switch(devicePlatform){
      case TargetPlatform.android :
        result = designStyle?.android;
        break;
      case TargetPlatform.iOS :
        result = designStyle?.ios;
        break;
      case TargetPlatform.windows:
        result = designStyle?.windows;
        break;
      default:
        result = designStyle?.android;
    }
    return result ?? PlatformStyle.Material;
  }
}

/// Apply a specific size to the selected element.
/// Will check the [data] for any "size" property and apply it accordingly.
class NssCustomSizeWidget extends StatelessWidget {
  final NssWidgetData? data;
  final Widget? child;

  const NssCustomSizeWidget({Key? key, this.data, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NssConfig? config = NssIoc().use(NssConfig);

    var size;
    // Check for size parameter in available custom theme. Override current if exists.
    final String customTheme = data!.theme ?? '';
    // Check if this widget has a size attached in attached custom theme.
    if (customTheme != null &&
        config!.markup!.customThemes != null &&
        config.markup!.customThemes!.containsKey(customTheme)) {
      if (config.markup!.customThemes![customTheme].containsKey('size')) {
        size = config.markup!.customThemes![customTheme]['size'];
      }
    }

    // Explicit size declaration will always get priority over custom theme declaration.
    if (data!.style == null) data!.style = {};
    if (data!.style!.containsKey('size')) {
      size = data!.style!['size'];
    }

    if (size == null) {
      return applySizeRestriction()!;
    }

    return SizedBox(
      width: ensureDouble(size[0]),
      height: ensureDouble(size[1]),
      child: child,
    );
  }

  /// Specific widgets such as image widget must have a size restriction.
  /// If the user did not specify any, 100/100 will be applied.
  Widget? applySizeRestriction() {
    switch (data!.type) {
      case NssWidgetType.profilePhoto:
      case NssWidgetType.image:
        return SizedBox(
          width: 100.0,
          height: 100.0,
          child: child,
        );
      default:
        return child;
    }
  }

  /// Make sure this value will be treated as a double.
  /// Useful for JSON parsed elements
  /// which should be treated as double but are parsed as integer.
  double? ensureDouble(num) => (num is int) ? num.toDouble() : num;
}
