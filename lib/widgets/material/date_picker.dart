import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/styles.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Date picker selection widget.
/// Widget can be opened in two modes:
/// 1. calendar.
/// 2. input.
/// Modes are switchable within the widget built in UI.
/// Widget supports multiple bind values with 'date' bindType.
class DatePickerWidget extends StatefulWidget {
  final NssWidgetData data;
  final String inputType;

  const DatePickerWidget({Key key, this.data, this.inputType})
      : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

/// Date picker selection widget state.
class _DatePickerWidgetState extends State<DatePickerWidget>
    with
        DecorationMixin,
        StyleMixin,
        LocalizationMixin,
        BindingMixin,
        ValidationMixin,
        DatePickerStyleMixin {
  DateTime _selectedDate = DateTime.now();

  // Trigger text field controller.
  final TextEditingController _controller = TextEditingController();

  DatePickerStyle _datePickerStyle;

  @override
  void initState() {
    super.initState();
    // Set text controller initial value.
    _controller.text = _parseValue();

    _datePickerStyle = widget.data.datePickerStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SemanticsWrapperWidget(
        accessibility: widget.data.accessibility,
        child: Padding(
          padding: getStyle(Styles.margin, data: widget.data),
          child: Consumer2<ScreenViewModel, BindingModel>(
            builder: (context, viewModel, bindings, child) {
              // Set initial binding value.
              _setInitialBindingValue(bindings);

              // Get general style fields for input view.
              final Color color = getStyle(Styles.fontColor,
                  data: widget.data, themeProperty: 'textColor');
              final borderSize = getStyle(Styles.borderSize, data: widget.data);
              final borderRadius =
                  getStyle(Styles.cornerRadius, data: widget.data);

              return Opacity(
                opacity: getStyle(Styles.opacity, data: widget.data),
                child: InkWell(
                  onTap: () {
                    // Trigger picker.
                    _selectDate(context);
                  },
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      fillColor: getStyle(Styles.background, data: widget.data),
                      disabledBorder: borderRadius == 0
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
                      labelText: localizedStringFor(widget.data.textKey),
                      labelStyle: TextStyle(
                          fontSize:
                              getStyle(Styles.fontSize, data: widget.data),
                          color: getStyle(Styles.fontColor,
                              data: widget.data, themeProperty: 'textColor'),
                          fontWeight:
                              getStyle(Styles.fontWeight, data: widget.data)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    maxLines: 1,
                    enabled: false,
                    textAlign: getStyle(Styles.textAlign, data: widget.data) ??
                        TextAlign.start,
                    style: TextStyle(
                        color: widget.data.disabled
                            ? color.withOpacity(0.3)
                            : color,
                        fontSize: getStyle(Styles.fontSize, data: widget.data),
                        fontWeight:
                            getStyle(Styles.fontWeight, data: widget.data)),
                    onSaved: (value) {
                      if (value.trim().isEmpty || _selectedDate == null) {
                        return;
                      }
                      debugPrint('onSaved with value:$value');

                      // Date picker does not currently support "parseAs" & "saveAs" property.
                      _bindOnSaved(bindings);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Sets the initial value of the widget according to available data or default date.
  _setInitialBindingValue(BindingModel bindings) {
    if (bindings.isStringTypeBinding(widget.data.bind)) {
      debugPrint('String binding');
      BindingValue bindingValue = getBindingText(widget.data, bindings);
      debugPrint('initial binding value = $bindingValue');
    } else if (bindings.isObjectTypeBinding(widget.data.bind)) {
      debugPrint('object binding');
    }
  }

  /// Initiate the date picker when date text is tapped.
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Refer step 1
      firstDate: DateTime(widget.data.startYear),
      lastDate: DateTime(widget.data.endYear),
      initialEntryMode: _pickerEntryMode(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                  fontSize: getStyle(Styles.fontSize, data: widget.data),
                  color: getPickerFontColor(_datePickerStyle, 'textColor'),
                  fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                    color: getStyle(Styles.fontColor,
                        data: widget.data, themeProperty: 'textColor'),
                    width: 1.0,
                  ),
                )),
            colorScheme: ColorScheme.light(
              primary: getPickerBackground(_datePickerStyle, 'primaryColor'),
            ),
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        // Update selected value.
        _selectedDate = picked;
        _controller.text = _parseValue();
      });
  }

  /// Parse the display value of the picker.
  String _parseValue() {
    return "${_selectedDate.toLocal()}".split(' ')[0];
  }

  /// Set the date picker selection mode: calendar or input are available.
  DatePickerEntryMode _pickerEntryMode() {
    if (widget.inputType == 'input') {
      return DatePickerEntryMode.input;
    }
    // Calendar display is the default display type.
    return DatePickerEntryMode.calendar;
  }

  /// Get the output date in iso8601.
  /// This is relevant for a single bind value.
  String _toIso8601Value() {
    return _selectedDate.toIso8601String();
  }

  /// Logic triggered on form save.
  /// Binding will be performed for widget according to dynamic type and specified binding type.
  _bindOnSaved(BindingModel bindings) {
    if (bindings.isObjectTypeBinding(widget.data.bind)) {
      // Parse binding object.
      DatePickerBinding objectBinding =
          DatePickerBinding.fromJson(widget.data.bind);
      debugPrint(objectBinding.toString());
      if (objectBinding.type == 'date') {
        if (objectBinding.day.isNotEmpty) {
          bindings.save(objectBinding.day, _selectedDate.day);
        }
        if (objectBinding.month.isNotEmpty) {
          bindings.save(objectBinding.month, _selectedDate.month);
        }
        if (objectBinding.year.isNotEmpty) {
          bindings.save(objectBinding.year, _selectedDate.year);
        }
      }
    } else if (bindings.isArrayTypeBinding(widget.data.bind)) {
      // Multiple bound fields as array type.
      // This option is available but will not be exposed via the documentation to the user yet.

      // When using the Date Picker, BindType date & none will match the date
      // according to the following:
      // [0] index = day of month.
      // [1] index = month of year.
      // [2] index = year.
      List<String> boundValues = widget.data.bind;
      if (boundValues.length > 0 && boundValues[0] != null) {
        bindings.save(boundValues[0], _selectedDate.day);
      }
      if (boundValues.length > 1 && boundValues[1] != null) {
        bindings.save(boundValues[1], _selectedDate.month);
      }
      if (boundValues.length > 2 && boundValues[2] != null) {
        bindings.save(boundValues[2], _selectedDate.year);
      }
    } else {
      // Single bind field. Binding data will be saved as Iso8601 format.
      final String boundValue = _toIso8601Value();
      bindings.save(widget.data.bind, boundValue);
    }
  }
}

/// Custom bindings for the [DatePickerWidget] widget class.
class DatePickerBinding {
  String type = 'date';
  String day = '';
  String month = '';
  String year = '';

  DatePickerBinding.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        day = json['day'],
        month = json['month'],
        year = json['year'];
}

/// Custom type mixin class for DatePickerWidget.
mixin DatePickerStyleMixin on StyleMixin {
  Color getPickerBackground(DatePickerStyle style, themeProperty) {
    if (style.primaryColor.isNotEmpty) {
      return getColor(style.primaryColor);
    } else if (themeProperty != null) {
      if (config.markup.theme != null) {
        final themeColor =
            config.markup.theme[themeProperty] ?? defaultTheme[themeProperty];
        return getThemeColor(themeColor);
      }
    }
    return Colors.black;
  }

  Color getPickerFontColor(DatePickerStyle style, themeProperty) {
    if (style.fontColor.isNotEmpty) {
      return getColor(style.fontColor);
    } else if (themeProperty != null) {
      if (config.markup.theme != null) {
        final themeColor =
            config.markup.theme[themeProperty] ?? defaultTheme[themeProperty];
        return getThemeColor(themeColor);
      }
    }
    return Colors.black;
  }
}
