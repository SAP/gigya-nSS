import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
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

class _SubmitWidgetState extends State<SubmitWidget>
    with WidgetDecorationMixin, NssActionsMixin, StyleMixin {
  @override
  Widget build(BuildContext context) {
    return expandIfNeeded(
        widget.data.expand,
        Padding(
          padding: getStyle(Styles.padding, widget.data.style),
          child: Consumer2<ScreenViewModel, BindingModel>(
            builder: (context, viewModel, bindings, child) {
              return Opacity(
                opacity: getStyle(Styles.opacity, widget.data.style),
                child: ButtonTheme(
                  buttonColor: getStyle(Styles.background, widget.data.style),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      getStyle(Styles.cornerRadius, widget.data.style),
                    ),
                  ),
                  child: RaisedButton(
                    elevation: getStyle(Styles.elevation, widget.data.style),
                    child: Text(
                      widget.data.textKey,
                      style: TextStyle(
                        fontSize: getStyle(Styles.fontSize, widget.data.style),
                        color: getStyle(Styles.fontColor, widget.data.style),
                        fontWeight: getStyle(Styles.fontWeight, widget.data.style),
                      ),
                    ),
                    onPressed: () {
                      viewModel.submitScreenForm(bindings.savedBindingData);
                      // Dismiss the keyboard. Important.
                      dismissKeyboardWith(context);
                    },
                  ),
                ),
              );
            },
          ),
        ));
  }
}
