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
      NssIoc().use(NssConfig).markup.localization.cast<String, dynamic>() ?? {NssInputValidator.defaultLangKey: {}};

  String localizedStringFor(String textKey) {
    String text = textKey;
    // If localization map does not contain the specified lang will route back to default.
    if (!_localizationMap.containsKey(lang)) {
      return text;
    }
    if (_localizationMap[lang].containsKey(textKey)) {
      text = _localizationMap[lang][textKey];
    } else if (_localizationMap[NssInputValidator.defaultLangKey].containsKey(textKey)) {
      text = _localizationMap[NssInputValidator.defaultLangKey][textKey];
    }
    debugPrint('Localized string for $lang = $text');
    return text;
  }
}
