import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

import 'package:gigya_native_screensets_engine/utils/extensions.dart';

class CheckboxWidget extends StatefulWidget {
  final NssWidgetData data;

  const CheckboxWidget({Key key, this.data}) : super(key: key);

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

/// General checkbox widget state.
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
                  BindingValue bindingValue = getBindingBool(widget.data, bindings);

                  if (bindingValue.error && !kReleaseMode) {
                    showBindingDoesNotMatchError(widget.data.bind);
                  }

                  _currentValue = bindingValue.value;
                  return Column(
                    children: <Widget>[
                      Row(
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
                                    bindings.save(widget.data.bind, !_currentValue);
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
                                              color: getStyle(Styles.fontColor, data: widget.data),
                                              fontSize: getStyle(Styles.fontSize, data: widget.data),
                                              fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                                        ),
                                )),
                          ),
                        ],
                      ),
                      Text(state.errorText != null ? state.errorText : '',
                          style: TextStyle(color: Colors.red, fontSize: 12))
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

class RadioGroupWidget extends StatefulWidget {
  final NssWidgetData data;

  const RadioGroupWidget({Key key, this.data}) : super(key: key);

  @override
  _RadioGroupWidgetState createState() => _RadioGroupWidgetState();
}

/// General radio group widget state.
class _RadioGroupWidgetState extends State<RadioGroupWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  String _groupValue;
  String _defaultValue;

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
        widget.data,
        Padding(
          padding: getStyle(Styles.margin, data: widget.data),
          child: sizeIfNeeded(
            widget.data,
            Consumer<BindingModel>(
              builder: (context, bindings, child) {
                BindingValue bindingValue = getBindingText(widget.data, bindings);

                if (bindingValue.error && !kReleaseMode) {
                  showBindingDoesNotMatchError(widget.data.bind);
                }

                _groupValue = bindingValue.value;
                if (_groupValue.isNullOrEmpty()) {
                  widget.data.options.forEach((option) {
                    if (option.defaultValue != null && option.defaultValue) {
                      _groupValue = option.value;
                    }
                  });
                }
                return ListView.builder(
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
                        style: TextStyle(
                          color: getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor'),
                          fontSize: getStyle(Styles.fontSize, data: widget.data),
                          fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                        ),
                      ),
                      groupValue: _groupValue,
                      activeColor: getThemeColor('enabledColor'),
                      // TODO: need to change the getter from theme.
                      onChanged: (String value) {
                        setState(() {
                          // Value needs to be parsed before form can be submitted.
                          if (widget.data.parseAs != null) {
                            // Markup parsing applies.
                            var parsed = parseAs(value.trim(), widget.data.parseAs);
                            if (parsed == null) {
                              engineLogger.e('parseAs field is not compatible with provided input');
                            }
                            bindings.save(widget.data.bind, parsed);
                            return;
                          }
                          // If parseAs field is not available try to parse according to schema.
                          var parsed = parseUsingSchema(value.trim(), widget.data.bind);
                          if (parsed == null) {
                            engineLogger.e('Schema type is not compatible with provided input');
                          }
                          bindings.save(widget.data.bind, parsed);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ));
  }
}

class DropDownButtonWidget extends StatefulWidget {
  final NssWidgetData data;

  const DropDownButtonWidget({Key key, this.data}) : super(key: key);

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

/// General dropdown button widget state.
class _DropDownButtonWidgetState extends State<DropDownButtonWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  String _dropdownValue;
  List<String> _dropdownItems = [];

  int indexFromDisplayValue(String value) {
    int index = 0;
    for (var i = 0; i < _dropdownItems.length; i++) {
      if (_dropdownItems[i] == value) {
        return i;
      }
    }
    return index;
  }

  int indexFromValue(String value) {
    int index = 0;
    for (var i = 0; i < widget.data.options.length; i++) {
      if (widget.data.options[i].value == value) {
        return i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
        widget.data,
        Padding(
          padding: getStyle(Styles.margin, data: widget.data),
          child: sizeIfNeeded(
            widget.data,
            Consumer<BindingModel>(builder: (context, bindings, child) {
              _dropdownItems.clear();

              BindingValue bindingValue = getBindingText(widget.data, bindings);

              if (bindingValue.error && !kReleaseMode) {
                showBindingDoesNotMatchError(widget.data.bind);
              }

              var bindValue = bindingValue.value;
              widget.data.options.forEach((option) {
                _dropdownItems.add(localizedStringFor(option.textKey));
                if (bindValue.isNullOrEmpty() && option.defaultValue != null && option.defaultValue) {
                  bindValue = option.value;
                }
              });
              _dropdownValue = _dropdownItems[indexFromValue(bindValue)];
              return DropdownButton<String>(
                isExpanded: true,
                value: _dropdownValue,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: getStyle(Styles.borderColor,
                      data: widget.data,
                      themeProperty: 'primaryColor'), // TODO: need to change the getter from theme.
                ),
                iconSize: 24,
                elevation: 4,
                underline: Container(
                  height: 1,
                  color: getStyle(Styles.borderColor,
                      data: widget.data), // TODO: need to change the getter from theme or borderColor.
                ),
                onChanged: (String newValue) {
                  setState(() {
                    var index = indexFromDisplayValue(newValue);
                    var updated = widget.data.options[index].value;

                    // Value needs to be parsed before form can be submitted.
                    if (widget.data.parseAs != null) {
                      // Markup parsing applies.
                      var parsed = parseAs(updated, widget.data.parseAs);
                      if (parsed == null) {
                        engineLogger.e('parseAs field is not compatible with provided input');
                      }
                      bindings.save(widget.data.bind, parsed);
                      return;
                    }
                    // If parseAs field is not available try to parse according to schema.
                    var parsed = parseUsingSchema(updated, widget.data.bind);
                    if (parsed == null) {
                      engineLogger.e('Schema type is not compatible with provided input');
                    }
                    bindings.save(widget.data.bind, parsed);
                  });
                },
                items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(
                          color: getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor'),
                          fontSize: getStyle(Styles.fontSize, data: widget.data),
                          fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                        )),
                  );
                }).toList(),
              );
            }),
          ),
        ));
  }
}
