import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:provider/provider.dart';

mixin NssActionsMixin {
  /// Force dismiss open keyboard from current focused widget.
  dismissKeyboardWith(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}

class SubmitWidget extends StatefulWidget {
  final NssWidgetData data;

  const SubmitWidget({Key key, this.data}) : super(key: key);

  @override
  _SubmitWidgetState createState() => _SubmitWidgetState();
}

class _SubmitWidgetState extends State<SubmitWidget> with WidgetDecorationMixin, NssActionsMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultPadding(),
      child: Consumer2<ScreenViewModel, BindingModel>(
        builder: (context, viewModel, bindings, child) {
          return RaisedButton(
            child: Text(widget.data.textKey),
            onPressed: () {
              viewModel.submitScreenForm(bindings.bindingData);
              // Dismiss the keyboard. Important.
              dismissKeyboardWith(context);
            },
          );
        },
      ),
    );
  }
}
