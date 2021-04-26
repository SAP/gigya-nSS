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
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Checkbox selection UI component.
class CheckboxWidget extends StatefulWidget {
  final NssWidgetData data;

  const CheckboxWidget({Key key, this.data}) : super(key: key);

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  bool _currentValue;

  @override
  void initState() {
    super.initState();

    // Initialize validators.
    initValidators(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final String displayText = localizedStringFor(widget.data.textKey);
    final Linkify linkify = Linkify(displayText);
    final bool linkified = linkify.containLinks(displayText);
    if (!linkified) linkify.dispose();
    return FormField(
      validator: (val) {
        return validateField(_currentValue.toString(), widget.data.bind);
      },
      builder: (state) {
        return Consumer2<ScreenViewModel, BindingModel>(builder: (context, viewModel, bindings, child) {
          BindingValue bindingValue = getBindingBool(widget.data, bindings);

          if (bindingValue.error && !kReleaseMode) {
            return showBindingDoesNotMatchError(widget.data.bind, errorText: bindingValue.errorText);
          }
          _currentValue = bindingValue.value;

          return Visibility(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SemanticsWrapperWidget(
                                accessibility: widget.data.accessibility,
                                child: Checkbox(
                                  activeColor: widget.data.disabled
                                      ? getThemeColor('disabledColor').withOpacity(0.3)
                                      : getThemeColor('enabledColor'),
                                  // TODO: need to verify if can improve it.
                                  checkColor: widget.data.disabled
                                      ? getThemeColor('disabledColor').withOpacity(0.3)
                                      : getThemeColor('secondaryColor'),
                                  value: _currentValue,
                                  onChanged: (bool val) {
                                    if (widget.data.disabled) {
                                      return null;
                                    }
                                    setState(() {
                                      bindings.save<bool>(widget.data.bind, val, saveAs: widget.data.sendAs);
                                    });
                                  },
                                ),
                              ),
                              Flexible(
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        bindings.save<bool>(widget.data.bind, !_currentValue, saveAs: widget.data.sendAs);
                                      });
                                    },
                                    child: Container(
                                      child: linkified
                                          ? linkify.linkify(widget.data, (link) {
                                              viewModel.linkifyTap(link);
                                            },
                                              getStyle(Styles.linkColor, data: widget.data, themeProperty: 'linkColor') ??
                                                  getColor('blue'))
                                          : Text(
                                              displayText,
                                              textAlign: getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.start,
                                              style: TextStyle(
                                                  color: getStyle(Styles.fontColor, data: widget.data),
                                                  fontSize: getStyle(Styles.fontSize, data: widget.data),
                                                  fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                                            ),
                                    )),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: state.errorText != null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                state.errorText != null ? state.errorText : '',
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
