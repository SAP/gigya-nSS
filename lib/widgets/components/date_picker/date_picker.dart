import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gigya_native_screensets_engine/models/styles.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/runtime_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/widgets/components/date_picker/date_picker_style.dart';
import 'package:gigya_native_screensets_engine/widgets/components/date_picker/date_picker_utils.dart';
import 'package:provider/provider.dart';

/// Date picker selection widget.
/// Widget can be opened in two modes:
/// 1. calendar.
/// 2. input.
/// Modes are switchable within the widget built in UI.
/// Widget supports multiple bind values with 'date' bindType.
class DatePickerWidget extends StatefulWidget {
  final NssWidgetData? data;
  final String? inputType;

  const DatePickerWidget({Key? key, this.data, this.inputType})
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
        VisibilityStateMixin,
        DatePickerStyleMixin,
        DatePickerUtilsMixin {
  DateTime? _selectedDate;
  DateTime? _initialDate;

  // Trigger text field controller.
  final TextEditingController _controller = TextEditingController();

  // Custom picker style object. Optional.
  DatePickerStyle? _datePickerStyle;

  @override
  void initState() {
    super.initState();
    _datePickerStyle = widget.data!.datePickerStyle;

    registerVisibilityNotifier(context, widget.data, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'DatePicker widget with bind: ${widget.data!.bind} build initiated');
    return Flexible(
      child: SemanticsWrapperWidget(
        accessibility: widget.data!.accessibility,
        child: Padding(
          padding: getStyle(Styles.margin, data: widget.data),
          child: Consumer2<ScreenViewModel, BindingModel>(
            builder: (context, viewModel, bindings, child) {
              // Set initial binding value.
              _setInitialBindingValue(bindings);

              // Get general style fields for input view.
              final Color? color = getStyle(Styles.fontColor,
                  data: widget.data, themeProperty: 'textColor');
              final borderSize = getStyle(Styles.borderSize, data: widget.data);
              final borderRadius =
                  getStyle(Styles.cornerRadius, data: widget.data);

              return Visibility(
                visible: isVisible(viewModel, widget.data),
                child: Opacity(
                  opacity: getStyle(Styles.opacity, data: widget.data),
                  child: GestureDetector(
                    onTap: () {
                      // Trigger picker.
                      if (!widget.data!.disabled!) {
                        isMaterial(context) ?  _showMaterialPickerSelection(context) : _showCupertinoPickerSelection(context);
                      }
                    },
                    child: Container(

                      foregroundDecoration: BoxDecoration(
                          color: Colors.transparent),
                      child: PlatformTextFormField(
                        enableInteractiveSelection: false,
                        controller: _controller,
                        enabled: false,
                        material: (_,__) => MaterialTextFormFieldData(
                          decoration: InputDecoration(
                            hintText: localizedStringFor(widget.data!.textKey) ?? '',
                            hintStyle: TextStyle(
                              color: widget.data!.disabled!
                                  ? getStyle(Styles.placeholderColor,
                                  data: widget.data,
                                  themeProperty: 'disabledColor')
                                  .withOpacity(0.3)
                                  : getStyle(Styles.placeholderColor,
                                  data: widget.data, themeProperty: 'textColor')
                                  .withOpacity(0.5),
                            ),
                            filled: true,
                            isDense: true,
                            fillColor:
                                getStyle(Styles.background, data: widget.data),
                            disabledBorder: !widget.data!.disabled!
                                ? borderRadius == 0
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
                                      )
                                : borderRadius == 0
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
                            // labelText: localizedStringFor(widget.data!.textKey),
                            // labelStyle: TextStyle(
                            //     fontSize:
                            //         getStyle(Styles.fontSize, data: widget.data),
                            //     color: widget.data!.disabled!
                            //         ? getThemeColor('disabledColor')
                            //             .withOpacity(0.3)
                            //         : getStyle(Styles.fontColor,
                            //             data: widget.data,
                            //             themeProperty: 'textColor'),
                            //     fontWeight:
                            //         getStyle(Styles.fontWeight, data: widget.data)),
                            //floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        cupertino: (_,__) => CupertinoTextFormFieldData(
                          placeholder: localizedStringFor(widget.data!.textKey) ?? '',
                          placeholderStyle: styleText(widget.data),
                          decoration: BoxDecoration(color:  getStyle(Styles.background, data: widget.data), backgroundBlendMode: BlendMode.color ),
                        ),

                        maxLines: 1,
                        textAlign:
                            getStyle(Styles.textAlign, data: widget.data) ??
                                TextAlign.start,
                        style: TextStyle(
                            color: widget.data!.disabled!
                                ? color!.withOpacity(0.3)
                                : color,
                            fontSize:
                                getStyle(Styles.fontSize, data: widget.data),
                            fontWeight:
                                getStyle(Styles.fontWeight, data: widget.data)),
                        onSaved: (value) {
                          if (value!.trim().isEmpty || _selectedDate == null) {
                            return;
                          }
                          debugPrint('onSaved with value:$value');

                          // Date picker does not currently support "parseAs" & "saveAs" property.
                          _bindDateSelection(bindings);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Initiate the date picker when date text is tapped.
  _showMaterialPickerSelection(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      fieldLabelText:
      localizedStringFor(_datePickerStyle!.labelText) ?? 'Enter Date',
      helpText: localizedStringFor(_datePickerStyle!.labelText) ?? 'Enter Date',
      initialDate: _selectedDate != null ? _selectedDate! : _initialDate!,
      // Refer step 1
      firstDate: getFirstDateFrom(widget.data!.startYear),
      lastDate: getLastDateFrom(widget.data!.endYear!),
      initialEntryMode: _pickerEntryMode(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                  fontSize: getStyle(Styles.fontSize, data: widget.data),
                  color: getPickerLabelColor(_datePickerStyle, 'textColor'),
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
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        // Update selected value.
        _selectedDate = picked;
        _controller.text = parseDateValue(_selectedDate, context);
      });
  }


  _showCupertinoPickerSelection(BuildContext context) async {
    final DateTime? picked = await showPlatformDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : _initialDate!,
      // Refer step 1
      firstDate: getFirstDateFrom(widget.data!.startYear),
      lastDate: getLastDateFrom(widget.data!.endYear!),
      cupertino: (_, __) => CupertinoDatePickerData(
        firstDate: getFirstDateFrom(widget.data!.startYear),
        lastDate: getLastDateFrom(widget.data!.endYear!),
        initialDate: _selectedDate != null ? _selectedDate! : _initialDate!,
      ),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        // Update selected value.
        _selectedDate = picked;
        _controller.text = parseDateValue(_selectedDate, context);
      });
  }

  /// Set the date picker selection mode: calendar or input are available.
  DatePickerEntryMode _pickerEntryMode() {
    if (widget.inputType == 'input') {
      return DatePickerEntryMode.input;
    }
    // Calendar display is the default display type.
    return DatePickerEntryMode.calendar;
  }

  /// Sets the initial value of the widget according to available data or default date.
  _setInitialBindingValue(BindingModel bindings) {
    // Either start first of day of start year or now
    _initialDate = widget.data!.endYear! > DateTime.now().year && widget.data!.startYear! < DateTime.now().year ? DateTime.now() : getFirstDateFrom(widget.data!.startYear!);

    // Selection has been made. No need to rest the initial value on setState().
    if (_selectedDate != null) {
      debugPrint('DatePicker (_setInitialBindingValue) - Selection available');
      _controller.text = parseDateValue(_selectedDate, context);
      _bindDateSelection(bindings);
      return;
    }

    // Binding data is not available no need for data parsing.
    if (!bindings.bindingDataAvailable()) {
      debugPrint(
          'DatePicker (_setInitialBindingValue) - Binding data is not available yet');
      _controller.text = '';
      return;
    }

    debugPrint(
        'DatePicker (_setInitialBindingValue) - Binding data is available');

    if (bindings.isStringTypeBinding(widget.data!.bind)) {
      debugPrint('DatePicker (_setInitialBindingValue) - String binding');

      String? bindingValue = bindings.getValue(widget.data!.bind);
      debugPrint(
          'DatePicker (_setInitialBindingValue) - initial binding value = $bindingValue');
      if (bindingValue != null) {
        _initialDate = fromIso8601Value(bindingValue);
      }
    } else if (bindings.isObjectTypeBinding(widget.data!.bind)) {
      debugPrint('DatePicker (_setInitialBindingValue) - Object binding');

      if (widget.data!.bind['type'] == 'date') {
        // Map binding object to obtain necessary keys.
        DatePickerBinding objectBinding =
            DatePickerBinding.fromJson(widget.data!.bind);

        // Default date time object that will act as a fallback value provider.
        DateTime now = DateTime.now();

        // Get bound values.
        int? day = now.day;
        if (objectBinding.day.isNotEmpty) {
          int? dayBinding = bindings.getValue<int>(objectBinding.day);
          if (dayBinding != 0) {
            day = dayBinding;
          }
        }
        int? month = now.month;
        if (objectBinding.month.isNotEmpty) {
          int? monthBinding = bindings.getValue<int>(objectBinding.month);
          if (monthBinding != 0) {
            month = monthBinding;
          }
        }
        int? year = now.year;
        if (objectBinding.year.isNotEmpty) {
          int? yearBinding = bindings.getValue<int>(objectBinding.year);
          if (yearBinding != 0) {
            year = yearBinding;
          }
        }
        _initialDate = DateTime(year!, month!, day!);
      } else {
        engineLogger!.e(
            'DatePicker (_setInitialBindingValue) - Wrong object binding for widget. Please follow the correct object binding guideline for DatePicker component.');
      }
    }
    _controller.text = parseDateValue(_initialDate, context);

    // Bind the initial date. If the user will not do any date selection. Make the form submit the initial date values.
    _bindDateSelection(bindings);
  }

  /// Binds the date picker selection value.
  /// Logic triggered for initial value or form onSaved method.
  /// Binding will be performed for widget according to dynamic type and specified binding type.
  _bindDateSelection(BindingModel bindings) {
    if (_selectedDate == null) {
      _selectedDate = _initialDate;
    }

    engineLogger!.d('DatePickerWidget: _bindDateSelection with ${_selectedDate?.toIso8601String()}');

    if (bindings.isObjectTypeBinding(widget.data!.bind)) {
      // Parse binding object.
      DatePickerBinding objectBinding =
          DatePickerBinding.fromJson(widget.data!.bind);
      debugPrint(objectBinding.toString());
      if (objectBinding.type == 'date') {
        if (objectBinding.day.isNotEmpty) {
          bindings.save(objectBinding.day, _selectedDate!.day);
        }
        if (objectBinding.month.isNotEmpty) {
          bindings.save(objectBinding.month, _selectedDate!.month);
        }
        if (objectBinding.year.isNotEmpty) {
          bindings.save(objectBinding.year, _selectedDate!.year);
        }
      }
    } else if (bindings.isArrayTypeBinding(widget.data!.bind)) {
      // Multiple bound fields as array type.
      // This option is available but will not be exposed via the documentation to the user yet.

      // When using the Date Picker, BindType date & none will match the date
      // according to the following:
      // [0] index = day of month.
      // [1] index = month of year.
      // [2] index = year.
      List<String> boundValues = widget.data!.bind;
      if (boundValues.length > 0) {
        bindings.save(boundValues[0], _selectedDate!.day);
      }
      if (boundValues.length > 1) {
        bindings.save(boundValues[1], _selectedDate!.month);
      }
      if (boundValues.length > 2) {
        bindings.save(boundValues[2], _selectedDate!.year);
      }
    } else {
      // Single bind field. Binding data will be saved as Iso8601 format.
      final String boundValue = toIso8601Value(_selectedDate!);
      bindings.save(widget.data!.bind, boundValue);
    }
  }
}

/// Custom bindings for the [DatePickerWidget] widget class.
class DatePickerBinding {
  String type = 'date';
  String day = '';
  String month = '';
  String year = '';

  DatePickerBinding.fromJson(Map<dynamic, dynamic> json)
      : type = json['type'] ?? 'date',
        day = json['day'] ?? '',
        month = json['month'] ?? '',
        year = json['year'] ?? '';
}
