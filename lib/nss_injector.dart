import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/theme/nss_decoration_mixins.dart';

enum NssWidgetType { label, input, email, password, submit }

class NssWidgetFactory {
  Widget create(NssWidgetType name, NssWidget data) {
    switch (name) {
      case NssWidgetType.label:
        // TODO: Handle this case.
        return DecoratedText(widgetData: data);
        break;
      case NssWidgetType.input:
        // TODO: Handle this case.
        break;
      case NssWidgetType.email:
        // TODO: Handle this case.
        break;
      case NssWidgetType.password:
        // TODO: Handle this case.
        break;
      case NssWidgetType.submit:
        // TODO: Handle this case.
        break;
    }
    return Container();
  }
}

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
          color: getColor("blue"),
        ),
      ),
    );
  }
}
