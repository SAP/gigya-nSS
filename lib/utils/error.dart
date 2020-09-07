class ErrorUtils {
  // Global error keys. Can be overriden using localization map.
  static const schemaErrorKeyRequired = 'error-schema-required-validation';
  static const schemaErrorKeyRegEx = 'error-schema-regex-validation';
  static const schemaErrorKeyCheckbox = 'error-schema-checkbox-validation';
  static const profileErrorImageUpload = 'error-photo-failed-upload';
  static const profileErrorImageSize = 'error-photo-image-size';
  static const canceledError = 'error-operation-canceled';

  void addDefaultError(Map<String, dynamic> localization, String key, String defaultString) {
    if (!localization['_default'].containsKey(key)) {
      localization['_default'][key] = defaultString;
    }
  }

  void addDefultStringValues(Map<String, dynamic> localization) {
    addDefaultError(localization, schemaErrorKeyRequired, 'This field is required');
    addDefaultError(localization, schemaErrorKeyRegEx, 'Please enter a valid value');
    addDefaultError(localization, schemaErrorKeyCheckbox, 'Checked field is mandatory');
    addDefaultError(localization, profileErrorImageUpload, 'Failed to upload. Please try again');
    addDefaultError(localization, profileErrorImageSize, 'Image exceeded file-size limits');
    addDefaultError(localization, profileErrorImageSize, 'Image exceeded file-size limits');
  }
}
