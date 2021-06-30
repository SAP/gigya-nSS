import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/widgets/material/image.dart';
import 'package:provider/provider.dart';

class ContainerWidget extends StatelessWidget with StyleMixin, DecorationMixin {
  final NssWidgetData data;
  final Widget child;

  ContainerWidget({
    Key key,
    this.data,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isNested = data.isNestedContainer ?? false;
    return Consumer2<ScreenViewModel, BindingModel>(
      builder: (context, viewModel, binding, widget) {
        return SemanticsWrapperWidget(
          accessibility: data.accessibility,
          child: Visibility(
            visible: isVisible(viewModel, data.showIf),
            child: isNested
                ? Flexible(
                    child: containerContent(),
                  )
                : containerContent(),
          ),
        );
      },
    );
  }

  Widget containerContent() {
    var background = getStyle(Styles.background, styles: data.style);
    return Padding(
      padding: getStyle(Styles.margin, styles: data.style),
      child: Opacity(
        opacity: getStyle(Styles.opacity, styles: data.style),
        child: Stack(
          children: <Widget>[
            (background is ImageWidget) ? Positioned.fill(child: background) : Container(),
            Container(
              width: containerWidth(),
              height: containerHeight(),
              decoration: BoxDecoration(
                color: background is Color ? background : Colors.transparent,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  double containerWidth() {
    var size = data.style['size'];
    return size != null
        ? size[0] == 0
            ? null
            : ensureDouble(size[0])
        : null;
  }

  double containerHeight() {
    var size = data.style['size'];
    return size != null
        ? size[0] == 0
            ? null
            : ensureDouble(size[1])
        : null;
  }
}
