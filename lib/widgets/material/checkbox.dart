import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
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
    with
        DecorationMixin,
        BindingMixin,
        StyleMixin,
        LocalizationMixin,
        ValidationMixin {
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
    return expandIfNeeded(
      widget.data,
      FormField(
        validator: (val) {
          return validateField(_currentValue.toString(), widget.data.bind);
        },
        builder: (state) {
          return Padding(
            padding: getStyle(Styles.margin, data: widget.data),
            child: sizeIfNeeded(
              widget.data,
              Consumer2<ScreenViewModel, BindingModel>(
                builder: (context, viewModel, bindings, child) {
                  BindingValue bindingValue =
                      getBindingBool(widget.data, bindings);

                  if (bindingValue.error && !kReleaseMode) {
                    return showBindingDoesNotMatchError(widget.data.bind, errorText: bindingValue.errorText);
                  }

                  _currentValue = bindingValue.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Checkbox(
                            activeColor: getThemeColor('enabledColor'),
                            // TODO: need to verify if can improve it.
                            checkColor: getThemeColor('secondaryColor'),
                            value: _currentValue,
                            onChanged: (bool val) {
                              setState(() {
                                bindings.save(widget.data.bind, val);
                              });
                            },
                          ),
                          Flexible(
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    bindings.save(
                                        widget.data.bind, !_currentValue);
                                  });
                                },
                                child: Container(
                                  child: linkified
                                      ? linkify.linkify(
                                          widget.data,
                                          (link) {
                                            viewModel.linkifyTap(link);
                                          },
                                        )
                                      : Text(
                                          displayText,
                                          style: TextStyle(
                                              color: getStyle(Styles.fontColor,
                                                  data: widget.data),
                                              fontSize: getStyle(
                                                  Styles.fontSize,
                                                  data: widget.data),
                                              fontWeight: getStyle(
                                                  Styles.fontWeight,
                                                  data: widget.data)),
                                        ),
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          state.errorText != null ? state.errorText : '',
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
