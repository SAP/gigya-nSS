import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:provider/provider.dart';

class LabelWidget extends StatelessWidget with WidgetDecorationMixin, BindingMixin {
  final NssWidgetData data;

  const LabelWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(data.expand, Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(
        builder: (context, bindings, child) {
          return Text(
            getText(data, bindings),
            style: TextStyle(fontSize: 14.0 //TODO Default text style (hard coded).
                ),
          );
        },
      ),
    ));
  }
}
