import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:provider/provider.dart';

class LabelWidget extends StatelessWidget with WidgetDecorationMixin, BindingMixin, StyleMixin {
  final NssWidgetData data;

  LabelWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
      data,
      Padding(
        padding: getStyle(Styles.margin, data: data),
        child: sizeIfNeeded(
          data,
          Consumer2<ScreenViewModel, BindingModel>(
            builder: (context, viewModel, bindings, child) {
              final String text = getText(data, bindings);
              final Linkify linkify = Linkify(text);
              final bool linkified = linkify.containLinks(text);
              if (!linkified) linkify.dispose();
              return Opacity(
                opacity: getStyle(Styles.opacity, data: data),
                child: linkified
                    ? linkify.linkify(
                        data,
                        (link) {
                          viewModel.linkifyTap(link);
                        },
                      )
                    : Text( // TODO: aliagnment is missing
                        text,
                        style: TextStyle(
                          fontSize: getStyle(Styles.fontSize, data: data),
                          color: getStyle(Styles.fontColor, data: data, themeProperty: 'textColor'),
                          fontWeight: getStyle(Styles.fontWeight, data: data),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}