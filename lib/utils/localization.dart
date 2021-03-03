import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';

mixin LocalizationMixin {
  /// Selected language. Injected to markup using native builder.
  /// Used '_default' if not available.
  final String lang = NssIoc().use(NssConfig).markup.lang ?? '_default';

  /// Parsed localization map.
  final Map<String, dynamic> _localizationMap =
      NssIoc().use(NssConfig).markup.localization.cast<String, dynamic>() ?? {'_default': {}};

  /// Get the localized string for the provided [textKey].
  /// If the specific key is not available within the selected language map, it will
  /// fallback to the "_default" mapping.
  /// Original "textKey" value will only be displayed if no "_default" language mapping is available.
  String localizedStringFor(String textKey) {
    String text = textKey;
    String usedLang = lang;
    // If localization map does not contain the specified lang will route back to default.
    if (!_localizationMap.containsKey(usedLang)) {
      usedLang = '_default';
    }
    if (_localizationMap[usedLang].containsKey(textKey)) {
      text = _localizationMap[usedLang][textKey];
    }
    return text;
  }

  /// Fetch specific entries from localization map that [startWith] a specific string and
  /// can be split using the provided [pattern].
  Map<dynamic, dynamic> entriesInMapThat(String startWith, String pattern) {
    final map = {};
    _localizationMap.forEach((key, value) {
      if (key.startsWith(startWith)) {
        var split = key.split(pattern);
        if (split.length <= 1) return;
        // Lowercase value to avoid quality miss matches.
        map[split[1].toLowerCase()] = value;
      }
    });
    return map;
  }
}
