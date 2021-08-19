import 'package:gigya_native_screensets_engine/models/option.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';
import 'package:gigya_native_screensets_engine/widgets/material/social.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';

@JsonSerializable(anyMap: true)
class NssWidgetData {
  String bind;
  NssWidgetType type;
  String textKey;
  @JsonKey(defaultValue: NssStack.vertical)
  NssStack stack;
  NssAlignment alignment;
  List<NssWidgetData> children;
  String api;
  dynamic defaultValue;
  List<NssOption> options;
  @JsonKey(defaultValue: {})
  Map<String, dynamic> style;
  String theme;
  @JsonKey(defaultValue: {})
  Map<String, dynamic> validations;

  // Optional values: 'number'|'boolean'|'string'
  String parseAs;
  String sendAs;

  // social login button
  NssSocialProvider provider;
  String iconURL;
  @JsonKey(defaultValue: true)
  bool iconEnabled;
  @JsonKey(defaultValue: [])
  List<NssSocialProvider> providers;
  @JsonKey(defaultValue: 4)
  int columns;
  @JsonKey(defaultValue: 1)
  int rows;
  @JsonKey(defaultValue: false)
  bool hideTitles;

  // Image widget
  String url;
  String fallback;

  @JsonKey(name: 'default')
  dynamic defaultPlaceholder;

  @JsonKey(defaultValue: true)
  bool allowUpload;

  @JsonKey(defaultValue: false)
  bool disabled;

  String showIf;

  Countries countries;

  @JsonKey(defaultValue: false)
  bool isNestedContainer;

  @JsonKey(defaultValue: {'label': '', 'hint': ''})
  Accessibility accessibility;

  String placeholder;

  dynamic storeAsArray;

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
    this.storeAsArray,
  });

  factory NssWidgetData.fromJson(Map<String, dynamic> json) => _$NssWidgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$NssWidgetDataToJson(this);

  bool boolDefaultValue() => defaultValue as bool;
}

@JsonSerializable(anyMap: true)
class Countries {
  @JsonKey(defaultValue: 'auto')
  String defaultSelected;
  @JsonKey(defaultValue: [])
  List<String> include;
  @JsonKey(defaultValue: [])
  List<String> exclude;
  @JsonKey(defaultValue: true)
  bool showIcons;

  Countries({this.defaultSelected, this.include, this.exclude, this.showIcons});

  factory Countries.fromJson(Map<String, dynamic> json) => _$CountriesFromJson(json);

  Map<String, dynamic> toJson() => _$CountriesToJson(this);
}

@JsonSerializable(anyMap: true)
class Accessibility {
  @JsonKey(defaultValue: '')
  String label;
  @JsonKey(defaultValue: '')
  String hint;

  Accessibility({
    this.label,
    this.hint,
  });

  factory Accessibility.fromJson(Map<String, dynamic> json) => _$AccessibilityFromJson(json);

  Map<String, dynamic> toJson() => _$AccessibilityToJson(this);
}
