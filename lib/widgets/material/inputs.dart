import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
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
    with WidgetDecorationMixin, BindingMixin, StyleMixin {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
        widget.data,
        Padding(
          padding: getStyle(Styles.margin, widget.data.style),
          child: Consumer<BindingModel>(
            builder: (context, bindings, child) {
              final placeHolder = getText(widget.data, bindings);
              _textEditingController.text = placeHolder;
              final borderColor = getStyle(Styles.borderColor, widget.data.style);
              final borderSize = getStyle(Styles.borderSize, widget.data.style);
              final borderRadius = getStyle(Styles.cornerRadius, widget.data.style);

              return Opacity(
                opacity: getStyle(Styles.opacity, widget.data.style),
                child: TextFormField(
                  obscureText: widget.data.type == NssWidgetType.passwordInput,
                  controller: _textEditingController,
                  style: TextStyle(
                      color: getStyle(Styles.fontColor, widget.data.style),
                      fontSize: getStyle(Styles.fontSize, widget.data.style),
                      fontWeight: getStyle(Styles.fontWeight, widget.data.style)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: getStyle(Styles.background, widget.data.style),
                    hintText: widget.data.textKey,
                    hintStyle: TextStyle(
                      color: getStyle(Styles.fontColor, widget.data.style).withOpacity(0.5),
                    ),
                    focusedBorder: borderRadius == 0
                        ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, // TODO: need to take color from theme.
                        width: borderSize+2,
                      ),
                    )
                        : OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      borderSide: BorderSide(
                        color: Colors.blue, // TODO: need to take color from theme.
                        width: borderSize,
                      ),
                    ),
                    enabledBorder: borderRadius == 0
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: borderColor,
                              width: borderSize,
                            ),
                          )
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            borderSide: BorderSide(
                              color: borderColor,
                              width: borderSize,
                            ),
                          ),
                  ),
                  validator: (input) {
                    //TODO: Static validations only.
                    return _validateField(input.trim());
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
        ));
  }

  /// Validate input according to instance type.
  String _validateField(input) {
    var validated = NssValidations.validate(input, forType: widget.data.type.name);

    switch (validated) {
      case NssInputValidation.failed:
        //TODO: Validation errors should be injected via the localization map.
        return 'Validation faild for type: ${widget.data.type.name}';
      case NssInputValidation.na:
        //TODO: Not available validator error should be injected via the localization map.
        engineLogger.d('Validator not specified for input widget type');
        break;
      case NssInputValidation.passed:
        break;
    }
    return null;
  }
}
