import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';

mixin LocalizationMixin {
  /// Selected language. Injected to markup using native builder.
  /// Used '_default' if not available.
  final String lang = NssIoc().use(NssConfig).markup.lang ?? NssInputValidator.defaultLangKey;

  /// Parsed localization map.
  final Map<String, dynamic> _localizationMap =
      NssIoc().use(NssConfig).markup.localization.cast<String, dynamic>() ??
          {NssInputValidator.defaultLangKey: {}};

  /// Get the localized string for the provided [textKey].
  /// If the specific key is not available within the selected language map, it will
  /// fallback to the "_default" mapping.
  /// Original "textKey" value will only be displayed if no "_default" language mapping is available.
  String localizedStringFor(String textKey) {
    String text = textKey;
    String usedLang = lang;
    // If localization map does not contain the specified lang will route back to default.
    if (!_localizationMap.containsKey(usedLang)) {
      usedLang = NssInputValidator.defaultLangKey;
    }
    if (_localizationMap[usedLang].containsKey(textKey)) {
      text = _localizationMap[usedLang][textKey];
    }
    return text;
  }
}
