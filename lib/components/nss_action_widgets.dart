import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class NssSubmitWidget extends StatelessWidget with NssWidgetDecorationMixin {
  final NssWidget widgetData;

  const NssSubmitWidget({Key key, this.widgetData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withPadding(24),
      child: RaisedButton(
        onPressed: () {
          // TODO: Need implementing the pressed logic.
        },
        child: Text(
            widgetData.textKey
        ),
      ),
    );
  }
}