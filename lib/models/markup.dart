import 'package:gigya_native_screensets_engine/models/routing.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:json_annotation/json_annotation.dart';

part 'markup.g.dart';

@JsonSerializable(anyMap: true)
class Markup {
  Platform platform;
  @JsonKey(defaultValue: false)
  bool platformAware;
  Map<String, Screen> screens;
  Routing routing;
  Map<String, dynamic> theme;
  Map<String, dynamic> customThemes;
  @JsonKey(defaultValue: '_default')
  String lang;
  @JsonKey(name: 'i18n', defaultValue: {'_default': {}})
  Map<String, dynamic> localization;
  @JsonKey(defaultValue: false)
  bool useSchemaValidations;

  Markup(
      {this.platformAware,
      this.screens,
      this.routing,
      this.theme,
      this.customThemes,
      this.useSchemaValidations});

  factory Markup.fromJson(Map<String, dynamic> json) => _$MarkupFromJson(json);

  Map<String, dynamic> toJson() => _$MarkupToJson(this);
}

@JsonSerializable(anyMap: true)
class Platform {
  String iso3166;

  Platform({
    this.iso3166,
  });

  factory Platform.fromJson(Map<String, dynamic> json) => _$PlatformFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformToJson(this);
}
