import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';

class ContainerWidget extends StatelessWidget with StyleMixin {
  final Widget child;
  final Map<String, dynamic> style;
  final bool isScreen;

  ContainerWidget({Key key, this.child, this.style, this.isScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var background = getStyle(Styles.background, style);

    return Padding(
      padding: getStyle(Styles.padding, style),
      child: Container(
        decoration: isScreen == false ? BoxDecoration(
          color: background is Color ? background : null,
          image: background is NetworkImage ? DecorationImage(
            fit: BoxFit.cover,
            image: background,
          ) : null
        ) : null,
        child: child,
      ),
    );
  }
}
