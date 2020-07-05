import 'package:flutter/foundation.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum Validator { required, regex }

extension ValidatorEx on Validator {
  String get name => describeEnum(this);
}

/// Base class for all custom input validators.
class NssInputValidator with LocalizationMixin {
  bool enabled;
  String errorKey;
  String format;

  static const defaultLangKey = '_default';
  static const schemaErrorKeyRequired = 'error-schema-required-validation';
  static const schemaErrorKeyRegEx = 'error-schema-regex-validation';
  static const schemaErrorKeyCheckbox = 'error-schema-checkbox-validation';

  static const unAttachTag = '#';

  NssInputValidator.requiredFromSchema()
      : enabled = true,
        errorKey = schemaErrorKeyRequired;

  NssInputValidator.regExFromSchema(String format)
      : enabled = true,
        errorKey = schemaErrorKeyRegEx,
        format = format;

  NssInputValidator.from(Map<String, dynamic> json)
      : enabled = json["enabled"],
        errorKey = json["errorKey"],
        format = json["format"];

  String getError() {
    return localizedStringFor(errorKey);
  }
}

/// This mixin class is responsible for all component input validation.
/// Validations are avaia
mixin ValidationMixin {
  final Map<String, NssInputValidator> _markupValidators = {};
  final Map<String, NssInputValidator> _schemaValidators = {};

  final NssConfig config = NssIoc().use(NssConfig);

  Map<dynamic, dynamic> getSchemaObject(String key) {
    if (!config.markup.useSchemaValidations) {
      return null;
    }
    if (config.schema.containsKey(key.split('.').first)) {
      var schemaObject =
          config.schema[key.split('.').first][key.replaceFirst(key.split('.').first + '.', '')] ?? {};
      return schemaObject;
    }
    return null;
  }

  /// Parse markup validators. These validators are currently prioritized over schema validators.
  initMarkupValidators(Map<String, dynamic> validations) async {
    if (validations.isEmpty) {
      return;
    }
    // Casting is required because the data is dynamic forced due to native channeling.
    validations.cast<String, dynamic>().forEach((k, v) {
      _markupValidators[k] = NssInputValidator.from(v.cast<String, dynamic>());
    });
  }

  /// Parse4 schema according to relvant key.
  initSchemaValidators(String key) async {
    if (!config.markup.useSchemaValidations) {
      return;
    }
    var schemaObject = getSchemaObject(key);
    if (schemaObject == null) return;
    if (schemaObject[Validator.required.name] == true) {
      _schemaValidators[Validator.required.name] = NssInputValidator.requiredFromSchema();
    }
    if (schemaObject.containsKey('format')) {
      String dirty = schemaObject['format'].toString().trim();
      dirty = dirty.replaceAll('regex(\'', '');
      final regex = dirty.substring(0, dirty.length - 2);
      engineLogger.d('regex = $regex');
      _schemaValidators[Validator.regex.name] = NssInputValidator.regExFromSchema(regex);
    }
  }

  /// Validate the input filed before submission is called.
  /// TODO: Inspect issuing the validation process adjacent to onFieldChanged property.
  String validateField(String input, String bind) {
    if (_markupValidators.isEmpty) {
      // Skip validation if bind is marked with `#`.
      if (bind.substring(0, 1) != NssInputValidator.unAttachTag) {
        return _validate(input, _schemaValidators);
      }
    }
    return _validate(input, _markupValidators);
  }

  String _validate(String input, Map<String, NssInputValidator> validators) {
    // Validate required field.
    if (input.isEmpty && validators.containsKey(Validator.required.name)) {
      final NssInputValidator requiredValidator = validators[Validator.required.name];
      if (requiredValidator.enabled) {
        return requiredValidator.getError();
      }
    }
    // Validated regex field.
    if (input.isNotEmpty && validators.containsKey(Validator.regex.name)) {
      final NssInputValidator regexValidator = validators[Validator.regex.name];
      final RegExp regExp = RegExp(regexValidator.format);
      final bool match = regExp.hasMatch(input);
      if(regexValidator.format == 'tr' && input != 'true') {
        regexValidator.errorKey = NssInputValidator.schemaErrorKeyCheckbox;
        return regexValidator.getError();
      }
      if (regexValidator.enabled && !match) {
        return regexValidator.getError();
      }
    }
    return null;
  }

  dynamic parseAs(String value, String type) {
    String source = value.trim();
    switch (type) {
      case 'number':
        return int.tryParse(source) ?? double.tryParse(source);
      case 'integer':
        return int.tryParse(value) ?? value;
      case 'double':
      case 'float':
      case 'date':
        return double.tryParse(value) ?? value;
      case 'boolean':
        return source.toLowerCase() == 'true';
      default:
        return value;
    }
  }

  dynamic parseUsingSchema(String value, String key) {
    if (!config.markup.useSchemaValidations) {
      return value.trim();
    }
    var schemaObject = getSchemaObject(key);
    if (schemaObject == null) return value.trim();

    String parse = schemaObject['type'] ?? 'string';
    return parseAs(value, parse);
  }
}
