import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Radio group UI selection componenet.
class RadioGroupWidget extends StatefulWidget {
  final NssWidgetData data;

  const RadioGroupWidget({Key key, this.data}) : super(key: key);

  @override
  _RadioGroupWidgetState createState() => _RadioGroupWidgetState();
}

class _RadioGroupWidgetState extends State<RadioGroupWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  String _groupValue;
  String _defaultValue;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenViewModel, BindingModel>(builder: (context, viewModel, bindings, child) {
      BindingValue bindingValue = getBindingText(widget.data, bindings, asArray: widget.data.storeAsArray);

      if (bindingValue.error && !kReleaseMode) {
        return showBindingDoesNotMatchError(widget.data.bind, errorText: bindingValue.errorText);
      }

      _groupValue = bindingValue.value;
      if (_groupValue.isNullOrEmpty()) {
        widget.data.options.forEach((option) {
          if (option.defaultValue != null && option.defaultValue) {
            _groupValue = option.value;
          }
        });
      }
      return SemanticsWrapperWidget(
        accessibility: widget.data.accessibility,
        child: Visibility(
          visible: isVisible(viewModel, widget.data.showIf),
          child: Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: getStyle(Styles.fontColor,
                  data: widget.data, themeProperty: 'textColor'),
              disabledColor: getThemeColor('disabledColor'),
            ),
            child: Opacity(
              opacity: getStyle(Styles.opacity, data: widget.data),
              child: Container(
                color: getStyle(Styles.background, data: widget.data),
                child: Padding(
                  padding: getStyle(Styles.margin, data: widget.data),
                  child: NssCustomSizeWidget(
                    data: widget.data,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.data.options.length,
                      itemBuilder: (BuildContext lvbContext, int index) {
                        NssOption option = widget.data.options[index];
                        return RadioListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: option.value,
                          title: Text(
                            localizedStringFor(option.textKey),
                            textAlign:
                                getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.start,
                            style: TextStyle(
                              color: widget.data.disabled
                                  ? getThemeColor('disabledColor')
                                  : getStyle(Styles.fontColor,
                                      data: widget.data, themeProperty: 'textColor'),
                              fontSize: getStyle(Styles.fontSize, data: widget.data),
                              fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                            ),
                          ),
                          groupValue: _groupValue,
                          activeColor: widget.data.disabled
                              ? getThemeColor('disabledColor')
                              : getThemeColor('enabledColor'),
                          // TODO: need to change the getter from theme.
                          onChanged: (String value) {
                            if (widget.data.disabled) {
                              return null;
                            }
                            setState(() {
                              // Value needs to be parsed before form can be submitted.
                              if (widget.data.parseAs != null) {
                                // Markup parsing applies.
                                var parsed = parseAs(value.trim(), widget.data.parseAs);
                                if (parsed == null) {
                                  engineLogger
                                      .e('parseAs field is not compatible with provided input');
                                }
                                bindings.save<String>(widget.data.bind, parsed,
                                    saveAs: widget.data.sendAs);
                                return;
                              }
                              // If parseAs field is not available try to parse according to schema.
                              var parsed = parseUsingSchema(value.trim(), widget.data.bind);
                              if (parsed == null) {
                                engineLogger.e('Schema type is not compatible with provided input');
                              }
                              bindings.save<String>(widget.data.bind, parsed,
                                  saveAs: widget.data.sendAs);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
