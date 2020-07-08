import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';


/// Dropdown group UI selection component.
class DropDownButtonWidget extends StatefulWidget {
  final NssWidgetData data;

  const DropDownButtonWidget({Key key, this.data}) : super(key: key);

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

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
