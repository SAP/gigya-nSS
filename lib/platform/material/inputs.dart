import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/platform/factory.dart';
import 'package:provider/provider.dart';

class TextInputWidget extends StatefulWidget {
  final NssWidgetData data;

  const TextInputWidget({Key key, this.data}) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> with WidgetDecorationMixin, BindingMixin {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(widget.data.expand, Padding(
      padding: defaultPadding(),
      child: Consumer<BindingModel>(
        builder: (context, bindings, child) {
          final placeHolder = getText(widget.data, bindings);
          _textEditingController.text = placeHolder;
          return TextFormField(
            obscureText: widget.data.type == NssWidgetType.password,
            controller: _textEditingController,
            decoration: InputDecoration(hintText: widget.data.textKey),
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
