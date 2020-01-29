import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class NssLabelWidget extends StatelessWidget with NssWidgetDecorationMixin {
  final NssWidgetData widgetData;

  const NssLabelWidget({Key key, this.widgetData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withPadding(24),
      child: Text(
        widgetData.textKey,
      ),
    );
  }
}
