
import 'package:flutter/painting.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:gigya_native_screensets_engine/widgets/factory.dart';

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

  /// Check if first character of the [String] contain a '#'.
  bool containsHashtagPrefix() {
    return this.substring(0, 1) == NssInputValidator.propertyPrefix;
  }

  /// Remove '#' first character from string if exists.
  /// Will return a new [String] instance.
  String removeHashtagPrefix() {
    if (this.containsHashtagPrefix()) {
      return this.replaceFirst(NssInputValidator.propertyPrefix, '');
    }
    return this;
  }

  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
}

/// Extension for [Map] !containsKey
extension MapExt<T, V> on Map<T, V> {
  bool unavailable(T key) {
    return !this.containsKey(key);
  }
}

extension TextAlignExt on TextAlign {

  Alignment toAlignment(NssWidgetType type) {
    switch(this) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.end:
        return Alignment.centerRight;
      default:
        switch(type) {
          case NssWidgetType.submit:
            return Alignment.center;
          case NssWidgetType.dropdown:
            return Alignment.centerLeft;
          default:
            return Alignment.centerLeft;
        }
    }
  }
}
