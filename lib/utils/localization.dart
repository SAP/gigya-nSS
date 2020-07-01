import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';

mixin LocalizationMixin {
  /// Selected language. Injected to markup using native builder.
  /// Used '_default' if not available.
  final String lang = NssIoc().use(NssConfig).markup.lang ?? '_default';

  /// Parsed localization map.
  final Map<String, dynamic> _localizationMap =
      NssIoc().use(NssConfig).markup.localization.cast<String, dynamic>() ?? {'_default': {}};

  String localizedStringFor(String textKey) {
    String text = textKey;
    // If localization map does not contain the specified lang will route back to default.
    if (!_localizationMap.containsKey(lang)) {
      return text;
    }
    if (_localizationMap[lang].containsKey(textKey)) {
      text = _localizationMap[lang][textKey];
    } else if (_localizationMap['_default'].containsKey(textKey)) {
      text = _localizationMap['_default'][textKey];
    }
    debugPrint('Localized string for $lang = $text');
    return text;
  }
}
