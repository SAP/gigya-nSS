import 'package:gigya_native_screensets_engine/models/accessibility.dart';
import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/models/styles.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/material/social.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

/// Main widget data object.
@JsonSerializable(anyMap: true)
class NssWidgetData {
  // Widget type identifier.
  NssWidgetType? type;

  // Two way binding field. Can be String or String[].
  dynamic bind;

  // Localized text key.
  String? textKey;

  // Stack alignment - vertical | horizontal.
  @JsonKey(defaultValue: NssStack.vertical)
  NssStack? stack;

  // Inner widget alignment.
  NssAlignment? alignment;

  // Available children for container type widgets.
  List<NssWidgetData>? children;

  String? api;

  // Available default value for widget.
  dynamic defaultValue;

  // List of available options for option supported widgets.
  List<NssOption>? options;

  // Widget styles map.
  @JsonKey(defaultValue: {})
  Map<String, dynamic>? style;

  // Widget specific theme.
  String? theme;

  // Widget validation map.
  @JsonKey(defaultValue: {})
  Map<String, dynamic>? validations;

  // Optional values: 'number'|'boolean'|'string'
  String? parseAs;
  String? sendAs;

  // Social login provider for social login button.
  NssSocialProvider? provider;

  // Icon URL for social login button.
  String? iconURL;

  // Icon visually enabled for social login button.
  @JsonKey(defaultValue: true)
  bool? iconEnabled;

  // Social login providers for social login grid.
  @JsonKey(defaultValue: [])
  List<NssSocialProvider?>? providers;

  // Social login grid column count.
  @JsonKey(defaultValue: 4)
  int? columns;

  // Social login grid rows count.
  @JsonKey(defaultValue: 1)
  int? rows;

  // Hide titles optional for social login grid.
  @JsonKey(defaultValue: false)
  bool? hideTitles;

  // Image widget URL.
  String? url;

  // Image widget fallback URL.
  String? fallback;

  // Default placeholder for profile image.
  @JsonKey(name: 'default')
  dynamic defaultPlaceholder;

  // Allow upload option for profile image (will enable selection click).
  @JsonKey(defaultValue: true)
  bool? allowUpload;

  // Disable widget option.
  @JsonKey(defaultValue: false)
  bool? disabled;

  // Visible when option
  String? showIf;

  // Countries object for phone selection widget.
  Countries? countries;

  // Nested container identifier.
  @JsonKey(defaultValue: false)
  bool? isNestedContainer;

  // Widget accessibility extension.
  //@JsonKey(defaultValue: {'label': '', 'hint': ''})
  Accessibility? accessibility;

  // Widget placeholder string option.
  String? placeholder;

  dynamic storeAsArray;

  // Date widget year range start.
  @JsonKey(defaultValue: 1920)
  int? startYear;

  // Date widget year range end.
  @JsonKey(defaultValue: 2025)
  int? endYear;

  DatePickerStyle? datePickerStyle;

  @JsonKey(defaultValue: '')
  String? initialDisplay;

  // Routing trigger available for button widget
  @JsonKey(defaultValue: false)
  bool? useRouting;

  bool? confirmPassword;

  String? confirmPasswordPlaceholder;


  NssWidgetData({
    this.textKey,
    this.type,
    this.bind,
    this.stack,
    this.alignment,
    this.children,
    this.api,
    this.defaultValue,
    this.options,
    this.style,
    this.theme,
    this.validations,
    this.parseAs,
    this.sendAs,
    this.provider,
    this.iconURL,
    this.iconEnabled,
    this.providers,
    this.columns,
    this.rows,
    this.hideTitles,
    this.url,
    this.fallback,
    this.defaultPlaceholder,
    this.allowUpload,
    this.disabled,
    this.showIf,
    this.countries,
    this.isNestedContainer,
    this.accessibility,
    this.placeholder,
    this.startYear,
    this.endYear,
    this.datePickerStyle,
    this.initialDisplay,
    this.storeAsArray,
    this.useRouting,
    this.confirmPassword,
    this.confirmPasswordPlaceholder,
  });

  factory NssWidgetData.fromJson(Map<String, dynamic> json) =>
      _$NssWidgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetDataToJson(this);

  bool? boolDefaultValue() => defaultValue as bool?;
}

/// Phone input countries helper object.
@JsonSerializable(anyMap: true)
class Countries {
  @JsonKey(defaultValue: 'auto')
  String? defaultSelected;
  @JsonKey(defaultValue: [])
  List<String>? include;
  @JsonKey(defaultValue: [])
  List<String>? exclude;
  @JsonKey(defaultValue: true)
  bool? showIcons;

  Countries({this.defaultSelected, this.include, this.exclude, this.showIcons});

  factory Countries.fromJson(Map<String, dynamic> json) =>
      _$CountriesFromJson(json);

  Map<String, dynamic> toJson() => _$CountriesToJson(this);
}
