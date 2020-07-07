import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
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
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  final TextEditingController _textEditingController = TextEditingController(text: '');
  Map<String, NssInputValidator> _validators = {};
  bool _obscuredText = false;

  @override
  void initState() {
    super.initState();

    // Initialize validators.
    initMarkupValidators(widget.data.validations);
    initSchemaValidators(widget.data.bind);

    // Text obfuscation is true by default for password input type widget.
    _obscuredText = widget.data.type == NssWidgetType.passwordInput;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// Toggle text obfuscation state. Currently relevant only for password type componenet.
  _toggleTextObfuscationState() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  /// Define the widget keyboard type according to its main type or schema field.
  TextInputType getKeyboardType(String key) {
    if (widget.data.type == NssWidgetType.emailInput) return TextInputType.emailAddress;
    return getBoundKeyboardType(key);
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
                BindingValue bindingValue = getBindingText(widget.data, bindings);

                if (bindingValue.error && !kReleaseMode) {
                  return showBindingDoesNotMatchError(widget.data.bind);
                }

                String placeHolder = bindingValue.value;
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
                    keyboardType: getKeyboardType(widget.data.bind),
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
                                _toggleTextObfuscationState();
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
                        color: getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor')
                            .withOpacity(0.5),
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
                                color: getStyle(Styles.borderColor,
                                    data: widget.data, themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getStyle(Styles.borderColor,
                                    data: widget.data, themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            ),
                    ),
                    validator: (input) {
                      return validateField(input, widget.data.bind);
                    },
                    onSaved: (value) {
                      if (value.trim().isEmpty && placeHolder.isEmpty) {
                        return;
                      }
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
                    },
                  ),
                );
              },
            ),
          ),
        ));
  }
}
