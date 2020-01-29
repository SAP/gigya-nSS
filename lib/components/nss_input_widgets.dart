import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

class NssTextInputWidget extends StatelessWidget with NssWidgetDecorationMixin {
  final NssWidgetData widgetData;
  final Key formKey;

  const NssTextInputWidget({Key key, @required this.widgetData, @required this.formKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withPadding(24),
      child: TextFormField(
        key: formKey,
        obscureText: widgetData.type == NssWidgetType.password ? true : false,
        decoration: InputDecoration(hintText: widgetData.textKey),
      ),
    );
  }
}
