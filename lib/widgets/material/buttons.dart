import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:provider/provider.dart';

import '../../utils/logging.dart';

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
  final NssWidgetData? data;

  const SubmitWidget({Key? key, this.data}) : super(key: key);

  @override
  _SubmitWidgetState createState() => _SubmitWidgetState();
}

class _SubmitWidgetState extends State<SubmitWidget>
    with
        DecorationMixin,
        NssActionsMixin,
        StyleMixin,
        LocalizationMixin,
        VisibilityStateMixin {
  @override
  void initState() {
    super.initState();

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextAlign textAlign =
        getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.center;

    return SemanticsWrapperWidget(
      accessibility: widget.data!.accessibility,
      child: Padding(
        padding: getStyle(Styles.margin, data: widget.data),
        child: Consumer2<ScreenViewModel, BindingModel>(
          builder: (context, viewModel, bindings, child) {

            return Column(
              crossAxisAlignment: getCrossAxisAlignment(widget.data?.alignment ?? viewModel.screenAlignment),
              children: <Widget>[

                NssCustomSizeWidget(
                  data: widget.data,
                  child: Opacity(
                    opacity: getStyle(Styles.opacity, data: widget.data),
                    child: ButtonTheme(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: widget.data!.disabled!
                                  ? getThemeColor('disabledColor').withOpacity(0.3)
                                  : getStyle(Styles.borderColor, data: widget.data),
                              width:
                              getStyle(Styles.borderSize, data: widget.data) ??
                                  0,
                            ),
                            borderRadius: BorderRadius.circular(
                              getStyle(Styles.cornerRadius, data: widget.data),
                            ),
                          ),
                          primary: widget.data!.disabled!
                              ? getThemeColor('disabledColor').withOpacity(0.3)
                              : getStyle(Styles.background,
                              data: widget.data, themeProperty: 'primaryColor'),
                          elevation: getElevationStyleProperty(),
                        ),
                        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        // elevation: getElevationStyleProperty(),
                        // hoverElevation: isFlat() ? 0 : null,
                        // disabledElevation: isFlat() ? 0 : null,
                        // focusElevation: isFlat() ? 0 : null,
                        // highlightElevation: isFlat() ? 0 : null,
                        child: Align(
                          widthFactor: 1,
                          alignment: textAlign.toAlignment(widget.data!.type),
                          child: Text(
                            // Get localized submit text.
                            localizedStringFor(widget.data!.textKey)!,
                            style: TextStyle(
                              fontSize:
                                  getStyle(Styles.fontSize, data: widget.data),
                              color: getStyle(Styles.fontColor,
                                  data: widget.data,
                                  themeProperty: 'secondaryColor'),
                              fontWeight: getStyle(Styles.fontWeight,
                                  data: widget.data),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (widget.data!.disabled!) {
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
                    ? Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 8, bottom: 16),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          viewModel.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: getThemeColor('errorColor')),
                        ),
                      ),
                    )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }



  /// Set the elevation property of the button.
  /// Default will be set to 0.
  dynamic getElevationStyleProperty() {
    if (widget.data!.disabled!) return 0;
    return getStyle(Styles.elevation, data: widget.data) ?? 0;
  }

  dynamic isFlat() => getElevationStyleProperty() == 0;
}


class ButtonWidget extends StatefulWidget {
  final NssWidgetData? data;

  const ButtonWidget({Key? key, this.data}) : super(key: key);

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget>
    with
        DecorationMixin,
        NssActionsMixin,
        StyleMixin,
        LocalizationMixin,
        VisibilityStateMixin {
  @override
  void initState() {
    super.initState();

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextAlign textAlign =
        getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.center;

    return SemanticsWrapperWidget(
      accessibility: widget.data!.accessibility,
      child: Padding(
        padding: getStyle(Styles.margin, data: widget.data),
        child: Consumer2<ScreenViewModel, BindingModel>(
          builder: (context, viewModel, bindings, child) {
            if (widget.data?.iconURL == null) {
              widget.data?.iconEnabled = false;
            }

            return Column(
              crossAxisAlignment: getCrossAxisAlignment(widget.data?.alignment ?? viewModel.screenAlignment),
              children: <Widget>[
                NssCustomSizeWidget(
                  data: widget.data,
                  child: Opacity(
                    opacity: getStyle(Styles.opacity, data: widget.data),
                    child: ButtonTheme(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: widget.data!.disabled!
                                  ? getThemeColor('disabledColor').withOpacity(0.3)
                                  : getStyle(Styles.borderColor, data: widget.data),
                              width:
                              getStyle(Styles.borderSize, data: widget.data) ??
                                  0,
                            ),
                            borderRadius: BorderRadius.circular(
                              getStyle(Styles.cornerRadius, data: widget.data),
                            ),
                          ),
                          primary: widget.data!.disabled!
                              ? getThemeColor('disabledColor').withOpacity(0.3)
                              : getStyle(Styles.background,
                              data: widget.data, themeProperty: 'primaryColor'),
                          elevation: getElevationStyleProperty(),
                        ),
                        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        // elevation: getElevationStyleProperty(),
                        // hoverElevation: isFlat() ? 0 : null,
                        // disabledElevation: isFlat() ? 0 : null,
                        // focusElevation: isFlat() ? 0 : null,
                        // highlightElevation: isFlat() ? 0 : null,
                        child: Align(
                          widthFactor: 1,
                          alignment: textAlign.toAlignment(widget.data!.type),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: getMainAxisAlignment(widget.data!.alignment),
                            children: [
                              widget.data!.iconEnabled!
                                  ? SizedBox(
                                width: 40,
                                height: 34,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image(
                                    image: NetworkImage(widget.data!.iconURL!),
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              )
                                  : SizedBox(width: 8),
                              Text(
                                // Get localized submit text.
                                localizedStringFor(widget.data!.textKey)!,
                                style: TextStyle(
                                  fontSize:
                                  getStyle(Styles.fontSize, data: widget.data),
                                  color: getStyle(Styles.fontColor,
                                      data: widget.data,
                                      themeProperty: 'secondaryColor'),
                                  fontWeight: getStyle(Styles.fontWeight,
                                      data: widget.data),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () async {
                          if (widget.data!.disabled!) {
                            return null;
                          }
                          engineLogger!.d('start button api');

                          var res = await viewModel.anonSendApi(widget.data?.api ?? "", {});
                          engineLogger!.d('after response button api');

                          bindings.updateWith(res, alsoSaved: true);
                          engineLogger!.d('api result: ${res.toString()}');

                          Provider.of<RuntimeStateEvaluator>(
                              context,
                              listen: false)
                              .notifyChanged(
                              widget.data!.bind, "");

                          // Dismiss the keyboard. Important.
                          dismissKeyboardWith(context);
                        },
                      ),
                    ),
                  ),
                ),
                viewModel.isError()
                    ? Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 16),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      viewModel.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: getThemeColor('errorColor')),
                    ),
                  ),
                )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }



  /// Set the elevation property of the button.
  /// Default will be set to 0.
  dynamic getElevationStyleProperty() {
    if (widget.data!.disabled!) return 0;
    return getStyle(Styles.elevation, data: widget.data) ?? 0;
  }

  dynamic isFlat() => getElevationStyleProperty() == 0;
}
