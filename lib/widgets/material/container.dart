import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/widgets/material/image.dart';
import 'package:provider/provider.dart';

class ContainerWidget extends StatefulWidget {
  final NssWidgetData? data;
  final Widget? child;

  ContainerWidget({
    Key? key,
    this.data,
    this.child,
  }) : super(key: key);

  @override
  _ContainerWidgetState createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> with StyleMixin, DecorationMixin, VisibilityStateMixin {

  @override
  void initState() {
    super.initState();

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isNested = widget.data!.isNestedContainer ?? false;
    return Consumer2<ScreenViewModel, BindingModel>(
      builder: (context, viewModel, binding, inner) {
        return SemanticsWrapperWidget(
          accessibility: widget.data!.accessibility,
          child: Visibility(
            visible: isVisible(viewModel, widget.data),
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
    var background = getStyle(Styles.background, styles: widget.data!.style);
    return Padding(
      padding: getStyle(Styles.margin, styles: widget.data!.style),
      child: Opacity(
        opacity: getStyle(Styles.opacity, styles: widget.data!.style),
        child: Stack(
          children: <Widget>[
            (background is ImageWidget) ? Positioned.fill(child: background) : Container(),
            Container(
              width: containerWidth(),
              height: containerHeight(),
              decoration: BoxDecoration(
                color: background is Color ? background : Colors.transparent,
              ),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }

  double? containerWidth() {
    var size = widget.data!.style!['size'];
    return size != null
        ? size[0] == 0
            ? null
            : ensureDouble(size[0])
        : null;
  }

  double? containerHeight() {
    var size = widget.data!.style!['size'];
    return size != null
        ? size[0] == 0
            ? null
            : ensureDouble(size[1])
        : null;
  }
}
