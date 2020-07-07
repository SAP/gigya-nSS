import 'package:gigya_native_screensets_engine/utils/validation.dart';

/// Extension for [Iterable] instance. Null or empty check.
extension IterableExt on Iterable {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }
}

extension StringExt on String {
  bool isNullOrEmpty() {
    return this == null || this.isEmpty;
  }

  bool isAvailable() {
    return !isNullOrEmpty();
  }

  bool containsHashtagPrefix() {
    return this.substring(0, 1) == NssInputValidator.propertyPrefix;
  }

  String removeHashtagPrefix() {
    if (this.substring(0, 1) == NssInputValidator.propertyPrefix) {
      return this.replaceFirst(NssInputValidator.propertyPrefix, '');
    }
    return this;
  }
}

/// Extension for [Map] !containsKey
extension MapExt<T, V> on Map<T, V> {
  bool unavailable(T key) {
    return !this.containsKey(key);
  }
}
