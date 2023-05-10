import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/error.dart';
import 'package:gigya_native_screensets_engine/utils/linkify.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Checkbox selection UI component.
class CheckboxWidget extends StatefulWidget {
  final NssWidgetData? data;

  const CheckboxWidget({Key? key, this.data}) : super(key: key);

  @override
  _CheckboxWidgetState createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget>
    with
        DecorationMixin,
        BindingMixin,
        StyleMixin,
        LocalizationMixin,
        ValidationMixin,
        VisibilityStateMixin,
        ErrorMixin {
  bool? _currentValue;

  @override
  void initState() {
    super.initState();

    // Initialize validators.
    initValidators(widget.data!);

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final String displayText = localizedStringFor(widget.data!.textKey)!;
    final Linkify linkify = Linkify(displayText);
    final bool linkified = linkify.containLinks(displayText);
    if (!linkified) linkify.dispose();
    return FormField(
      validator: (dynamic val) {
        return validateBool(_currentValue ?? false, widget.data!.bind);
      },
      builder: (state) {
        return Consumer2<ScreenViewModel, BindingModel>(
            builder: (context, viewModel, bindings, child) {
          BindingValue bindingValue = getBindingBool(widget.data!, bindings,
              asArray: widget.data!.storeAsArray);

          // Check for binding error. Display on screen.
          if (bindingValueError(bindingValue)) {
            return bindingValueErrorDisplay(widget.data!.bind,
                errorText: bindingValue.errorText);
          }

          _currentValue = bindingValue.value;

          return Visibility(
            visible: isVisible(viewModel, widget.data),
            child: Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: getStyle(Styles.fontColor,
                    data: widget.data, themeProperty: 'textColor'),
                disabledColor: getThemeColor('disabledColor'),
              ),
              child: Opacity(
                opacity: getStyle(Styles.opacity, data: widget.data),
                child: Container(
                  color: getStyle(Styles.background, data: widget.data),
                  child: Padding(
                    padding: getStyle(Styles.margin, data: widget.data),
                    child: NssCustomSizeWidget(
                      data: widget.data,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SemanticsWrapperWidget(
                                accessibility: widget.data!.accessibility,
                                child: Theme(
                                  data: ThemeData(
                                      unselectedWidgetColor:
                                          widget.data!.disabled!
                                              ? getThemeColor('disabledColor')
                                                  .withOpacity(0.3)
                                              : getThemeColor('enabledColor')),
                                  child: getPlatformStyle(context) == PlatformStyle.Material ? buildMaterialCheckBox(bindings) : buildCupertinoSwitch(bindings)
                                ),
                              ),
                              Flexible(
                                child: GestureDetector(
                                    onTap: widget.data!.disabled!
                                        ? null
                                        : () {
                                            setState(() {
                                              bindings.save<bool>(
                                                  widget.data!.bind,
                                                  !_currentValue!,
                                                  saveAs: widget.data!.sendAs,
                                                  asArray: widget
                                                      .data!.storeAsArray);
                                            });
                                          },
                                    child: Container(
                                      child: linkified
                                          ? linkify.linkify(widget.data,
                                              (link) {
                                              viewModel.linkifyTap(link!);
                                            },
                                              // link color
                                              getStyle(Styles.linkColor,
                                                      data: widget.data,
                                                      themeProperty:
                                                          'linkColor') ??
                                                  getColor('blue'))
                                          : Text(
                                              displayText,
                                              textAlign: getStyle(
                                                      Styles.textAlign,
                                                      data: widget.data) ??
                                                  TextAlign.start,
                                              style: TextStyle(
                                                  color: widget.data!.disabled!
                                                      ? getThemeColor(
                                                              'disabledColor')
                                                          .withOpacity(0.3)
                                                      : getStyle(
                                                          Styles.fontColor,
                                                          data: widget.data),
                                                  fontSize: getStyle(
                                                      Styles.fontSize,
                                                      data: widget.data),
                                                  fontWeight: getStyle(
                                                      Styles.fontWeight,
                                                      data: widget.data)),
                                            ),
                                    )),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: state.errorText != null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                state.errorText != null ? state.errorText! : '',
                                textAlign: TextAlign.start,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget buildMaterialCheckBox(bindings){
    return Checkbox(
      tristate: false,
      activeColor: widget.data!.disabled!
          ? getThemeColor('disabledColor')
          .withOpacity(0.3)
          : getThemeColor('enabledColor'),
      checkColor: widget.data!.disabled!
          ? getThemeColor('disabledColor')
          .withOpacity(0.3)
          : getThemeColor('secondaryColor'),
      value: _currentValue,
      onChanged: (bool? val) {
        if (widget.data!.disabled!) {
          return null;
        }
        setState(() {
          bindings.save<bool?>(
              widget.data!.bind, val,
              saveAs: widget.data!.sendAs,
              asArray: widget.data!.storeAsArray);

          // Track runtime data change.
          Provider.of<RuntimeStateEvaluator>(
              context,
              listen: false)
              .notifyChanged(
              widget.data!.bind, val);
        });
      },
    );
  }

  Widget buildCupertinoSwitch(bindings){
    return CupertinoSwitch(
      value: _currentValue ?? false,
      onChanged: (bool? val) {
        if (widget.data!.disabled!) {
          return null;
        }
        setState(() {
          bindings.save<bool?>(
              widget.data!.bind, val,
              saveAs: widget.data!.sendAs,
              asArray: widget.data!.storeAsArray);

          // Track runtime data change.
          Provider.of<RuntimeStateEvaluator>(
              context,
              listen: false)
              .notifyChanged(
              widget.data!.bind, val);
        });
      },
      activeColor: widget.data!.disabled!
          ? getThemeColor('disabledColor')
          .withOpacity(0.3)
          : getThemeColor('enabledColor'),
      trackColor: widget.data!.disabled!
          ? getThemeColor('disabledColor')
          .withOpacity(0.3)
          : Colors.grey,
        //thumbColor: Colors.pink
    );
  }

  PlatformStyle getPlatformStyle(context){
    TargetPlatform? platform =  defaultTargetPlatform;
    PlatformStyleData? styles = PlatformProvider.of(context)?.settings.platformStyle;

    PlatformStyle? result;
    switch(platform){
      case TargetPlatform.android :
        result = styles?.android;
        break;
      case TargetPlatform.iOS :
        result = styles?.ios;
        break;
      default:
        result = styles?.android;


    }
    return result ?? PlatformStyle.Material;
  }

}
