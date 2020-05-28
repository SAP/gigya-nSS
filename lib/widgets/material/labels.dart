import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:provider/provider.dart';

class LabelWidget extends StatelessWidget with WidgetDecorationMixin, BindingMixin, StyleMixin {
  final NssWidgetData data;

  LabelWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
        data,
        Padding(
          padding: getStyle(Styles.margin, data.style),
          child: Consumer<BindingModel>(
            builder: (context, bindings, child) {
              return Opacity(
                opacity: getStyle(Styles.opacity, data.style),
                child: Text(
                  getText(data, bindings),
                  style: TextStyle(
                      fontSize: getStyle(Styles.fontSize, data.style),
                      color: getStyle(Styles.fontColor, data.style),
                      fontWeight: getStyle(Styles.fontWeight, data.style),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
