import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';

mixin LocalizationMixin {
  /// Selected language. Injected to markup using native builder.
  /// Used '_default' if not available.
  String lang = NssIoc().use(NssConfig).markup.lang ?? '_default';

  /// Parsed localization map.
  final Map<String, dynamic> _localizationMap =
      NssIoc().use(NssConfig).markup.localiation.cast<String, dynamic>() ?? {'_default': {}};

  String localizedStringFor(String textKey) {
    // If localization map does not contain the specified lang will route back to default.
    lang = _localizationMap.containsKey(lang) ? lang : '_default';
    final String text = (_localizationMap[lang].containsKey(textKey) ? _localizationMap[lang][textKey] : textKey) ?? '';
    debugPrint('Localized string for $lang = $text');
    return text;
  }
}
