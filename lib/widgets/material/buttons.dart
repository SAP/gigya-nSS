import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

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
    with DecorationMixin, NssActionsMixin, StyleMixin, LocalizationMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getStyle(Styles.margin, data: widget.data),
      child: Consumer2<ScreenViewModel, BindingModel>(
        builder: (context, viewModel, bindings, child) {
          TextAlign align = getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.center;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              customSizeWidget(
                widget.data,
                Opacity(
                  opacity: getStyle(Styles.opacity, data: widget.data),
                  child: ButtonTheme(
                    buttonColor: widget.data.disabled
                        ? getThemeColor('disabledColor').withOpacity(0.3)
                        : getStyle(Styles.background,
                            data: widget.data, themeProperty: 'primaryColor'),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: widget.data.disabled
                            ? getThemeColor('disabledColor').withOpacity(0.3)
                            : getStyle(Styles.borderColor,
                                data: widget.data, themeProperty: 'secondaryColor'),
                        width: getStyle(Styles.borderSize, data: widget.data) ?? 0,
                      ),
                      borderRadius: BorderRadius.circular(
                        getStyle(Styles.cornerRadius, data: widget.data),
                      ),
                    ),
                    child: RaisedButton(
                      elevation:
                          widget.data.disabled ? 0 : getStyle(Styles.elevation, data: widget.data),
                      child: Align(
                        alignment: align.toAlignment(widget.data.type),
                        child: Text(
                          // Get localized submit text.
                          localizedStringFor(widget.data.textKey),
                          style: TextStyle(
                            fontSize: getStyle(Styles.fontSize, data: widget.data),
                            color: getStyle(Styles.fontColor,
                                data: widget.data, themeProperty: 'secondaryColor'),
                            fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (widget.data.disabled) {
                          return null;
                        }
                        viewModel.submitScreenForm(bindings.savedBindingData);
                        // Dismiss the keyboard. Important.
                        dismissKeyboardWith(context);
                      },
                    ),
                  ),
                ),
              ),
              viewModel.isError()
                  ? Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            viewModel.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.0, color: getThemeColor('errorColor')),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          );
        },
      ),
    );
  }
}
