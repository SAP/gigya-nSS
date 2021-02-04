import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/widgets/events.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:provider/provider.dart';

/// Main text input component implementaion.
/// Widget support multiple sub implementaions such as 'emailInput'/'passowrdInput' and handles each special
/// states accordingly.
class TextInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const TextInputWidget({Key key, this.data}) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget>
    with
        DecorationMixin,
        BindingMixin,
        StyleMixin,
        LocalizationMixin,
        ValidationMixin,
        EngineEvents {
  final TextEditingController _textEditingController = TextEditingController(text: '');
  Map<String, NssInputValidator> _validators = {};
  bool _obscuredText = false;

  //TODO: errorMaxLines currently hard coded to 3 - add style property.
  final _errorMaxLines = 3;

  // Tracking text input in order to be able to send the previous input value in "onFieldChange" event invocation.
  String inputTracker = '';

  // Client is able to inject validation error using the "onFieldChange" event.
  String eventInjectedError;

  @override
  void initState() {
    super.initState();

    // Initialize validators.
    initValidators(widget.data);

    // Text obfuscation is true by default for password input type widget.
    _obscuredText = widget.data.type == NssWidgetType.passwordInput;
  }

  @override
  void dispose() {
    inputTracker = '';
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
    return Consumer2<ScreenViewModel, BindingModel>(
        builder: (context, viewModel, bindings, child) {
          BindingValue bindingValue = getBindingText(widget.data, bindings);

          if (bindingValue.error && !kReleaseMode) {
            return showBindingDoesNotMatchError(widget.data.bind,
                errorText: bindingValue.errorText);
          }

          String placeHolder = bindingValue.value;
          if (_textEditingController.text.isEmpty || _textEditingController.text != placeHolder) {
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

          final Color color = getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor');
          return Visibility(
            visible: isVisible(viewModel, widget.data.showIf),
            child: Flexible(
              child: Padding(
                padding: getStyle(Styles.margin, data: widget.data),
                child: customSizeWidget(
                    widget.data,
                    Opacity(
                      opacity: getStyle(Styles.opacity, data: widget.data),
                      child: TextFormField(
                        enabled: !widget.data.disabled,
                        keyboardType: getKeyboardType(widget.data.bind),
                        obscureText: _obscuredText,
                        controller: _textEditingController,
                        textAlign: getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.start,
                        style: TextStyle(
                            color: widget.data.disabled ? color.withOpacity(0.3) : color,
                            fontSize: getStyle(Styles.fontSize, data: widget.data),
                            fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                        decoration: InputDecoration(
                          errorMaxLines: _errorMaxLines,
                          filled: true,
                          suffixIcon: widget.data.type == NssWidgetType.passwordInput
                              ? IconButton(
                            onPressed: () {
                              bindings.save(widget.data.bind, _textEditingController.text.trim(), saveAs: widget.data.sendAs);
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
                            color: widget.data.disabled
                                ? getStyle(Styles.placeholderColor,
                                data: widget.data, themeProperty: 'disabledColor')
                                .withOpacity(0.3)
                                : getStyle(Styles.placeholderColor,
                                data: widget.data, themeProperty: 'textColor')
                                .withOpacity(0.5),
                          ),
                          disabledBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: getThemeColor('disabledColor').withOpacity(0.3),
                              // TODO: need to take color from theme.
                              width: borderSize + 2,
                            ),
                          )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            borderSide: BorderSide(
                              color: getThemeColor('disabledColor').withOpacity(0.3),
                              // TODO: need to take color from theme.
                              width: borderSize,
                            ),
                          ),
                          errorBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: getThemeColor('errorColor'),
                              // TODO: need to take color from theme.
                              width: borderSize + 2,
                            ),
                          )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            borderSide: BorderSide(
                              color: getThemeColor('errorColor'),
                              // TODO: need to take color from theme.
                              width: borderSize,
                            ),
                          ),
                          focusedErrorBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: getThemeColor('errorColor'),
                              // TODO: need to take color from theme.
                              width: borderSize + 2,
                            ),
                          )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            borderSide: BorderSide(
                              color: getThemeColor('errorColor'),
                              // TODO: need to take color from theme.
                              width: borderSize,
                            ),
                          ),
                          focusedBorder: borderRadius == 0
                              ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: getThemeColor('enabledColor'),
                              // TODO: need to take color from theme.
                              width: borderSize + 2,
                            ),
                          )
                              : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            borderSide: BorderSide(
                              color: getThemeColor('enabledColor'),
                              // TODO: need to take color from theme.
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
                          // Event injected error has priorty in field validation.
                          if (eventInjectedError != null) {
                            if (eventInjectedError.isEmpty) {
                              eventInjectedError = null;
                              return null;
                            }
                            return eventInjectedError;
                          }
                          // Field validation triggered.
                          return validateField(input, widget.data.bind);
                        },
                        onChanged: (s) {
                          onChanged(viewModel, s);
                        },
                        onSaved: (value) {
                          // Form field saved event triggered.
                          if (value.trim().isEmpty) {
                            return;
                          }
                          // Value needs to be parsed before form can be submitted.
                          if (widget.data.parseAs != null) {
                            // Markup parsing applies.
                            var parsed = parseAs(value.trim(), widget.data.parseAs);
                            if (parsed == null) {
                              engineLogger.e('parseAs field is not compatible with provided input');
                            }
                            bindings.save<String>(widget.data.bind, parsed, saveAs: widget.data.sendAs);
                            return;
                          }

                          // If parseAs field is not available try to parse according to schema.
                          var parsed = parseUsingSchema(value.trim(), widget.data.bind);
                          if (parsed == null) {
                            engineLogger.e('Schema type is not compatible with provided input');
                          }
                          bindings.save<String>(widget.data.bind, parsed, saveAs: widget.data.sendAs);
                        },
                      ),
                    )
                ),
              ),
            ),
          );
        }
    );
  }

  /// Send field changed event to be optionally handled in native events handler.
  void onChanged(ScreenViewModel viewModel, to) async {
    Map<String, dynamic> eventData = await fieldDidChange(
      viewModel.id,
      widget.data.bind,
      inputTracker,
      to,
    );

    if (eventData.isNotEmpty) {
      if (eventData.containsKey('error')) {
        // Error injected via native event override.
        eventInjectedError = eventData['error'];

        viewModel.requestScreenFormValidation();
      } else if (eventInjectedError != null) {
        // dispose of last injected error. Disposal should be fired once as the injected error
        // is then cleared.
        eventInjectedError = '';
        viewModel.requestScreenFormValidation();
      }
    }
    inputTracker = to;
  }
}
