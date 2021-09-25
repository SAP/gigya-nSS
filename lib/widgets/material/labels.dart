import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:provider/provider.dart';

class LabelWidget extends StatelessWidget with DecorationMixin, StyleMixin, LocalizationMixin, BindingMixin {
  final NssWidgetData data;

  LabelWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenViewModel, BindingModel>(
      builder: (context, viewModel, bindings, child) {
        BindingValue bindingValue = getBindingText(data, bindings);

        // Check for binding error.
        if (bindingValue.error && !kReleaseMode) {
          return showBindingDoesNotMatchError(data.bind, errorText: bindingValue.errorText);
        }

        // Binding validated.
        String text = bindingValue.value;
        if (text == null) {
          // Get localized label text.
          text = localizedStringFor(data.textKey);
        }

        // Apply link action if needed.
        final Linkify linkify = Linkify(text ?? '');
        final bool linkified = linkify.containLinks(text);
        if (!linkified) linkify.dispose();

        return SemanticsWrapperWidget(
          accessibility: data.accessibility,
          child: Visibility(
            visible: isVisible(viewModel, data),
            child: Padding(
              padding: getStyle(Styles.margin, data: data),
              child: NssCustomSizeWidget(
                data: data,
                child: Opacity(
                  opacity: getStyle(Styles.opacity, data: data),
                  child: Container(
                    color: getStyle(Styles.background, data: data),
                    child: linkified
                        ? linkify.linkify(data, (link) {
                            viewModel.linkifyTap(link);
                          }, getStyle(Styles.linkColor, data: data, themeProperty: 'linkColor') ?? getColor('blue'))
                        : Text(
                            text,
                            textAlign: getStyle(Styles.textAlign, data: data) ?? TextAlign.start,
                            style: TextStyle(
                              fontSize: getStyle(Styles.fontSize, data: data),
                              color: getStyle(Styles.fontColor, data: data, themeProperty: 'textColor'),
                              fontWeight: getStyle(Styles.fontWeight, data: data),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
