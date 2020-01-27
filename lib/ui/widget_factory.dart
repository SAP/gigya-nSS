
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/decoration/colors.dart';
import 'package:gigya_native_screensets_engine/decoration/widget_decorations.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';

enum WidgetType {
  label,
  input,
  email,
  password,
  submit
}

class SoleWidgetFactory {
  Widget create(WidgetType name, NSSWidget data) {
    switch(name) {
      case WidgetType.label:
        // TODO: Handle this case.
      return DecoratedText(widgetData: data);
        break;
      case WidgetType.input:
        // TODO: Handle this case.
        break;
      case WidgetType.email:
        // TODO: Handle this case.
        break;
      case WidgetType.password:
        // TODO: Handle this case.
        break;
      case WidgetType.submit:
        // TODO: Handle this case.
        break;
    }
    return Container();
  }

  Widget layoutText(NSSWidget data) {
    debugPrint(data.toString());
    return DecoratedText(widgetData: data);
  }
}

class DecoratedText extends StatelessWidget with WidgetGeneralDecorationMixin {

  final NSSWidget widgetData;

  const DecoratedText({Key key, this.widgetData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withPadding(16),
      child: Text(
        widgetData.textKey,
        style: TextStyle(
          fontSize: 14,
          color: ColorUtils().parseColor("blue"),
        ),
      ),
    );
  }

}
