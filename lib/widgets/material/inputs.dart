import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:provider/provider.dart';

class TextInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const TextInputWidget({Key key, this.data}) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin {
  final TextEditingController _textEditingController = TextEditingController(text: '');
  Map<String, NssInputValidator> _validators = {};
  bool _obscuredText = false;

  @override
  void initState() {
    super.initState();
    _initValidators();
    _obscuredText = widget.data.type == NssWidgetType.passwordInput;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  _togglePasswordVisibility() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

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
                String placeHolder = getBindingText(widget.data, bindings);
                if (_textEditingController.text.isEmpty) {
                  _textEditingController.text = placeHolder;
                } else {
                  _textEditingController.value = _textEditingController.value.copyWith(
                    text: _textEditingController.text,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: _textEditingController.text.length),
                    ),
                  );
                }
                final borderSize = getStyle(Styles.borderSize, data: widget.data);
                final borderRadius = getStyle(Styles.cornerRadius, data: widget.data);

                return Opacity(
                  opacity: getStyle(Styles.opacity, data: widget.data),
                  child: TextFormField(
                    obscureText: _obscuredText,
                    controller: _textEditingController,
                    style: TextStyle(
                        color: getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor'),
                        fontSize: getStyle(Styles.fontSize, data: widget.data),
                        fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                    decoration: InputDecoration(
                      filled: true,
                      suffixIcon: widget.data.type == NssWidgetType.passwordInput
                          ? IconButton(
                              onPressed: () {
                                bindings.save(widget.data.bind, _textEditingController.text.trim());
                                _togglePasswordVisibility();
                              },
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: _obscuredText ? Colors.black12 : Colors.black54,
                              ),
                            )
                          : null,
                      fillColor: getStyle(Styles.background, data: widget.data),
                      hintText: localizedStringFor(widget.data.textKey),
                      hintStyle: TextStyle(
                        color:
                            getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor').withOpacity(0.5),
                      ),
                      focusedBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: getThemeColor('enabledColor'), // TODO: need to take color from theme.
                                width: borderSize + 2,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getThemeColor('enabledColor'), // TODO: need to take color from theme.
                                width: borderSize,
                              ),
                            ),
                      enabledBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: getStyle(Styles.borderColor, data: widget.data, themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getStyle(Styles.borderColor, data: widget.data, themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            ),
                    ),
                    validator: (input) {
                      return _validateField(input.trim(), widget.data.bind);
                    },
                    onSaved: (value) {
                      if (value.trim().isEmpty && placeHolder.isEmpty) {
                        return;
                      }
                      bindings.save(widget.data.bind, value.trim());
                    },
                  ),
                );
              },
            ),
          ),
        ));
  }

  /// Parse input validation map an prepare for form validation request.
  _initValidators() async {
    if (widget.data.validations == null) {
      return;
    }
    widget.data.validations.cast<String, dynamic>().forEach((k, v) {
      _validators[k] = NssInputValidator.from(v.cast<String, dynamic>());
    });
  }

  /// Validate input according to instance type.
  String _validateField(String input, String key) {

    if (_validators.isEmpty) {
      if (config.schema.containsKey(key.split('.').first)) {
        var validator = config.schema[key.split('.').first][key.replaceFirst(key.split('.').first + '.', '')] ?? {};
        if (input.isEmpty && validator['required'] == true) {
          return 'Error';
        }

        if (input.isNotEmpty && validator.containsKey('format')) {
          final regex = validator['format'].toString().replaceAll("regex('", '').replaceAll("')", '');

          final RegExp regExp = RegExp(regex);
          bool match = regExp.hasMatch(input);
          if (!match) {
            //TODO: Should be localized string.
            return 'regexValidator.errorKey';
          }
        }
      }
      return null;
    }
    // Validate required field.
    if (input.isEmpty && _validators.containsKey('required')) {
      NssInputValidator requiredValidator = _validators['required'];
      if (requiredValidator.enabled) {
        //TODO: Should be localized string.
        return localizedStringFor(requiredValidator.errorKey);
      }
    }
    // Validated regex field.
    if (input.isNotEmpty && _validators.containsKey('regex')) {
      NssInputValidator regexValidator = _validators['regex'];
      final RegExp regExp = RegExp(regexValidator.value);
      bool match = regExp.hasMatch(input);
      if (regexValidator.enabled && !match) {
        //TODO: Should be localized string.
        return localizedStringFor(regexValidator.errorKey);
      }
    }
    return null;
  }
}
