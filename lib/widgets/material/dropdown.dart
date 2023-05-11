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
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Dropdown group UI selection component.
class DropDownButtonWidget extends StatefulWidget {
  final NssWidgetData? data;

  const DropDownButtonWidget({Key? key, this.data}) : super(key: key);

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

class _DropDownButtonWidgetState extends State<DropDownButtonWidget>
    with
        DecorationMixin,
        BindingMixin,
        StyleMixin,
        LocalizationMixin,
        ValidationMixin,
        VisibilityStateMixin,
        ErrorMixin {
  String? _dropdownDisplayValue;
  String? _value;
  List<String?> _dropdownItems = [];
  String? _placeholder;


  @override
  void initState() {
    controller = TextEditingController(text: _dropdownDisplayValue);
    _placeholder = widget.data!.placeholder ?? null;
    super.initState();

    // Initialize validators.
    initValidators(widget.data!);

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  int indexFromDisplayValue(String? value) {
    int index = 0;
    for (var i = 0; i < _dropdownItems.length; i++) {
      if (_dropdownItems[i] == value) {
        return i;
      }
    }
    return index;
  }

  int indexFromValue(String? value) {
    if (value == null) return -1;
    int index = 0;
    for (var i = 0; i < widget.data!.options!.length; i++) {
      if (widget.data!.options![i].value == value) {
        return i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenViewModel, BindingModel>(
        builder: (context, viewModel, bindings, child) {
      _dropdownItems.clear();

      BindingValue bindingValue = getBindingText(widget.data!, bindings,
          asArray: widget.data!.storeAsArray);

      // Check for binding error. Display on screen.
      if (bindingValueError(bindingValue)) {
        return bindingValueErrorDisplay(widget.data!.bind,
            errorText: bindingValue.errorText);
      }

      var bindValue = bindingValue.value;
      var defaultValue;
      widget.data!.options!.forEach((option) {
        _dropdownItems.add(localizedStringFor(option.textKey));
        if (option.defaultValue != null && option.defaultValue!) {
          defaultValue = option.value;
        }
      });

      if (defaultValue == null && bindValue == null && _placeholder != null) {
        _dropdownDisplayValue = null;
      } else if (defaultValue != null && bindValue == null) {
        _dropdownDisplayValue = _dropdownItems[indexFromValue(defaultValue)];
        _value = defaultValue;

        setOption(_dropdownDisplayValue, bindings);
        debugPrint(_value);
        debugPrint(
            'No binding value for dropdown -> default value will be displayed');
        controller.text = _dropdownDisplayValue!;
      } else {
        var index = indexFromValue(bindValue);
        _dropdownDisplayValue =
            index == -1 ? _dropdownItems[0] : _dropdownItems[index];
        _value = index == -1
            ? widget.data!.options![0].value
            : widget.data!.options![index].value;
        debugPrint(
            'Binding value available for dropdown and will be displayed');
      }

      var borderSize = getStyle(Styles.borderSize, data: widget.data);
      var borderRadius = getStyle(Styles.cornerRadius, data: widget.data);
      var borderColor = getStyle(Styles.borderColor,
          data: widget.data, themeProperty: 'disabledColor');
      final Color? color = getStyle(Styles.fontColor,
          data: widget.data, themeProperty: 'textColor');

      return SemanticsWrapperWidget(
        accessibility: widget.data!.accessibility,
        child: Visibility(
          visible: isVisible(viewModel, widget.data),
          child: Opacity(
            opacity: getStyle(Styles.opacity, data: widget.data),
            child: Padding(
              padding: getStyle(Styles.margin, data: widget.data),
              child: Container(
                child: NssCustomSizeWidget(
                  data: widget.data,
                  child: IgnorePointer(
                    ignoring: widget.data!.disabled!,
                    child: getPlatformStyle(context) == PlatformStyle.Material ?
                    buildDropdownButtonFormField(borderRadius, borderSize, color, bindings, context) :
                    buildCupertinoPicker(borderRadius, borderSize, color, bindings, context) ,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  DropdownButtonFormField<String> buildDropdownButtonFormField(borderRadius, borderSize, Color? color, BindingModel bindings, BuildContext context) {
    return DropdownButtonFormField<String>(
                    validator: (input) {
                      // Field validation triggered.
                      return validateField(_value, widget.data!.bind);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                      isDense: true,
                      filled: true,
                      fillColor:
                          getStyle(Styles.background, data: widget.data),
                      hintText: localizedStringFor(widget.data!.textKey),
                      hintStyle: TextStyle(
                        color: widget.data!.disabled!
                            ? getStyle(Styles.placeholderColor,
                                    data: widget.data,
                                    themeProperty: 'disabledColor')
                                .withOpacity(0.3)
                            : getStyle(Styles.placeholderColor,
                                    data: widget.data,
                                    themeProperty: 'textColor')
                                .withOpacity(0.5),
                      ),
                      disabledBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: getThemeColor('disabledColor')
                                    .withOpacity(0.3),
                                width: borderSize + 2,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getThemeColor('disabledColor')
                                    .withOpacity(0.3),
                                width: borderSize,
                              ),
                            ),
                      errorBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: getThemeColor('errorColor'),
                                width: borderSize + 2,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getThemeColor('errorColor'),
                                width: borderSize,
                              ),
                            ),
                      focusedErrorBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: getThemeColor('errorColor'),
                                width: borderSize + 2,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getThemeColor('errorColor'),
                                width: borderSize,
                              ),
                            ),
                      focusedBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: getThemeColor('enabledColor'),
                                width: borderSize + 2,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getThemeColor('enabledColor'),
                                width: borderSize,
                              ),
                            ),
                      enabledBorder: borderRadius == 0
                          ? UnderlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: getStyle(Styles.borderColor,
                                    data: widget.data,
                                    themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderRadius)),
                              borderSide: BorderSide(
                                color: getStyle(Styles.borderColor,
                                    data: widget.data,
                                    themeProperty: "disabledColor"),
                                width: borderSize,
                              ),
                            ),
                    ),
                    isExpanded: true,
                    style: TextStyle(
                        color: widget.data!.disabled!
                            ? color!.withOpacity(0.3)
                            : color,
                        fontSize:
                            getStyle(Styles.fontSize, data: widget.data),
                        fontWeight:
                            getStyle(Styles.fontWeight, data: widget.data)),
                    hint: Text(
                      localizedStringFor(_placeholder) ?? '',
                      style: TextStyle(
                        color: widget.data!.disabled!
                            ? getStyle(Styles.placeholderColor,
                                    data: widget.data,
                                    themeProperty: 'disabledColor')
                                .withOpacity(0.3)
                            : getStyle(Styles.placeholderColor,
                                    data: widget.data,
                                    themeProperty: 'textColor')
                                .withOpacity(0.5),
                      ),
                    ),
                    dropdownColor:
                        getStyle(Styles.background, data: widget.data),
                    value: _dropdownDisplayValue,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: widget.data!.disabled!
                          ? getThemeColor('disabledColor').withOpacity(0.3)
                          : getStyle(Styles.borderColor,
                              data: widget.data,
                              themeProperty: 'primaryColor'),
                    ),
                    elevation: 4,
                    onChanged: (String? newValue) {
                      setState(() {
                        setOption(newValue, bindings);
                        _dropdownDisplayValue = newValue;
                        var index = indexFromDisplayValue(newValue);
                        _value = index == -1
                            ? null
                            : widget.data!.options![index].value;

                        debugPrint("onchange value:$_value");
                        // Track runtime data change.
                        Provider.of<RuntimeStateEvaluator>(context,
                                listen: false)
                            .notifyChanged(widget.data!.bind, newValue);
                      });
                    },
                    items: _dropdownItems
                        .map<DropdownMenuItem<String>>((String? value) {
                      TextAlign align =
                          getStyle(Styles.textAlign, data: widget.data) ??
                              TextAlign.start;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Align(
                          alignment: align.toAlignment(widget.data!.type),
                          child: Text(value!,
                              style: TextStyle(
                                color: widget.data!.disabled!
                                    ? getThemeColor('disabledColor')
                                        .withOpacity(0.3)
                                    : getStyle(Styles.fontColor,
                                        data: widget.data,
                                        themeProperty: 'textColor'),
                                fontSize: getStyle(Styles.fontSize,
                                    data: widget.data),
                                fontWeight: getStyle(Styles.fontWeight,
                                    data: widget.data),
                              )),
                        ),
                      );
                    }).toList(),
                  );
  }

  static const double _kItemExtent = 32.0;
  late TextEditingController controller;

  CupertinoTextFormFieldRow buildCupertinoPicker(borderRadius, borderSize, Color? color, BindingModel bindings, BuildContext context) {
   return CupertinoTextFormFieldRow(
        controller: controller,
        // textAlign: TextAlign.center,
        prefix: Text(localizedStringFor(widget.data!.placeholder) ?? ''),
        readOnly: true,
        enableInteractiveSelection: false,
        padding: EdgeInsets.all(0),
        // decoration: BoxDecoration(
        //   border: Border.all(width: 1),
        //   borderRadius: BorderRadius.circular(4),
        // ),
      onTap: () => _showDialog(
        CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: _kItemExtent,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int index) {
            setState(() {
              controller.text = _dropdownItems[index]!;
            });

          },
          children:
          List<Widget>.generate(_dropdownItems.length, (int index) {
            return Center(
              child: Text(
                _dropdownItems[index]!,
              ),
            );
          }),
        ),
      ),
       validator: (String? value) {
         return validateField(value, widget.data!.bind);
       },
      // This displays the selected fruit name.
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          // Provide a background color for the popup.
          color: CupertinoColors.systemBackground.resolveFrom(context),
          // Use a SafeArea widget to avoid system overlaps.
          child: SafeArea(
            top: false,
            child: child,
          ),
        ));
  }


  setOption(String? newValue, BindingModel bindings) {
    if (widget.data!.disabled!) {
      return;
    }

    var index = indexFromDisplayValue(newValue);
    var updated = widget.data!.options![index].value;

    // Value needs to be parsed before form can be submitted.
    if (widget.data!.parseAs != null) {
      // Markup parsing applies.
      var parsed = parseAs(updated!, widget.data!.parseAs);
      if (parsed == null) {
        engineLogger!.e('parseAs field is not compatible with provided input');
      }
      bindings.save<String?>(widget.data!.bind, parsed,
          saveAs: widget.data!.sendAs);
      return;
    }
    // If parseAs field is not available try to parse according to schema.
    var parsed = parseUsingSchema(updated!, widget.data!.bind);
    if (parsed == null) {
      engineLogger!.e('Schema type is not compatible with provided input');
    }
    bindings.save<String?>(widget.data!.bind, parsed,
        saveAs: widget.data!.sendAs);
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
