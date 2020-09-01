import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

class ContainerWidget extends StatelessWidget with StyleMixin, DecorationMixin {
  final Widget child;
  final Map<String, dynamic> style;
  final bool isScreen;

  ContainerWidget({Key key, this.child, this.style, this.isScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var background = getStyle(Styles.background, styles: style);
    var size = style['size'];
    return Padding(
      padding: getStyle(Styles.margin, styles: style),
      child: Opacity(
        opacity: getStyle(Styles.opacity, styles: style),
        child: Container(
          width:
              size != null ? size[0] == 0 ? null : ensureDouble(size[0]) : null,
          height:
              size != null ? size[0] == 0 ? null : ensureDouble(size[1]) : null,
          decoration: isScreen == false
              ? BoxDecoration(
                  color: background is Color ? background : null,
                  image: background is NetworkImage
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: background,
                        )
                      : null)
              : null,
          child: child,
        ),
      ),
    );
  }
}
