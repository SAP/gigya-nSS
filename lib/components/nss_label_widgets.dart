
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class DecoratedText extends StatelessWidget with NssWidgetDecorationMixin {
  final NssWidget widgetData;

  const DecoratedText({Key key, this.widgetData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withPadding(16),
      child: Text(
        widgetData.textKey,
        style: TextStyle(
          fontSize: 14,
          color: parseColor("blue"),
        ),
      ),
    );
  }
}