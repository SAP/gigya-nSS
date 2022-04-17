import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorUtils {
  // Global error keys. Can be overridden using localization map.
  static const schemaErrorKeyRequired = 'error-schema-required-validation';
  static const schemaErrorKeyRegEx = 'error-schema-regex-validation';
  static const schemaErrorKeyCheckbox = 'error-schema-checkbox-validation';
  static const profileErrorImageUpload = 'error-photo-failed-upload';
  static const profileErrorImageSize = 'error-photo-image-size';
  static const canceledError = 'error-operation-canceled';

  void addDefaultError(
      Map<String, dynamic> localization, String key, String defaultString) {
    if (localization.containsKey('_default') &&
        !localization['_default'].containsKey(key)) {
      localization['_default'][key] = defaultString;
    }
  }

  void addDefaultStringValues(Map<String, dynamic> localization) {
    addDefaultError(
        localization, schemaErrorKeyRequired, 'This field is required');
    addDefaultError(
        localization, schemaErrorKeyRegEx, 'Please enter a valid value');
    addDefaultError(
        localization, schemaErrorKeyCheckbox, 'Checked field is mandatory');
    addDefaultError(localization, profileErrorImageUpload,
        'Failed to upload. Please try again');
    addDefaultError(
        localization, profileErrorImageSize, 'Image exceeded file-size limits');
    addDefaultError(
        localization, profileErrorImageSize, 'Image exceeded file-size limits');
  }
}

mixin ErrorMixin {

  bool bindingValueError(bindingValue) {
    return bindingValue.error && (!kReleaseMode || kIsWeb);
  }

  /// Display a non matching error for the provided binding markup [key].
  Widget bindingValueErrorDisplay(String? key, {String? errorText}) {
    return Container(
      color: Colors.amber.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          errorText ?? 'Dev error: Binding key: $key does not exist in schema',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            color: Colors.lightBlue,
          ),
        ),
      ),
    );
  }
}
