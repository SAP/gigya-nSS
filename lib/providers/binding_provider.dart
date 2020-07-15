import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

/// Screen data binding model used for each [NssScreen]. Data is injected using the
/// flow initialization process from the native bridge.
class BindingModel with ChangeNotifier {
  final int _limit = 10;
  final regExp = new RegExp(r'^(.*)[[0-9]]$');

  // map of supported types with default return value.
  final typeSupported = {String: '', bool: false};

  // default return when type not supported
  final defaultReturn = '';

  Map<String, dynamic> _bindingData = {};
  Map<String, dynamic> savedBindingData = {};

  /// Update biding data once available. Updating the data will trigger rebuild for
  /// every child widget in the view tree.
  void updateWith(Map<String, dynamic> map) {
    _bindingData = map;
    notifyListeners();
  }

  dynamic getSavedValue<T>(String key) {
    return getValue<T>(key, savedBindingData);
  }

  /// Get the relevant bound data using the String [key] reference.
  dynamic getValue<T>(String key, [Map<String, dynamic> dataObject]) {
    var bindingData = dataObject ?? _bindingData;

    var keys = key.split('.');
    var nextKey = 0;
    var nextData = bindingData[keys[nextKey]];
    dynamic value;

    if (keys.length >= _limit || nextData == null) {
      return typeSupported[T] ?? defaultReturn;
    }

    while (value == null) {
      if (typeSupported[nextData.runtimeType] != null) {
        value = nextData;
      } else if (regExp.hasMatch(keys[nextKey])) {
        var arrayKeyData = keys[nextKey].split('[');
        var arrayKey = arrayKeyData[0];
        var arrayIndex = int.parse(arrayKeyData[1].replaceAll(']', ''));

        nextData = arrayIndex < (nextData[arrayKey] as List).length
            ? nextData[arrayKey][arrayIndex]
            : '';
        keys[nextKey] = arrayKey;
      } else {
        nextKey++;
        if (nextKey > keys.length - 1) {
          return typeSupported[T] ?? defaultReturn;
        }

        if (nextData[keys[nextKey]] != null) {
          nextData = nextData[keys[nextKey]];
        }
      }
    }

    return value;
  }

  /// Save a new [key] / [value] pair for form submission.
  save<T>(String key, T value) {
    // Remove `#` mark before submit.
    final String checkedKey = key.removeHashtagPrefix();

    saveTo(checkedKey, value, savedBindingData);
    saveTo(checkedKey, value, _bindingData);
  }

  /// Update the binding data map with required [key] and [value].
  saveTo<T>(String key, T value, Map<String, dynamic> tmpData) {
    var keys = key.split('.');
    var nextKey = 0;

    if (tmpData[keys[nextKey]] == null) {
      tmpData[keys[nextKey]] = {};
    }

    var finish = false;

    if (keys.length == 1) {
      tmpData[key] = value;
      return;
    }

    var nextData = tmpData[keys[nextKey]];

    while (finish == false) {
      nextKey++;

      if (nextKey >= keys.length - 1) {
        finish = true;
      }

      if (nextData != null) {
        if (nextData[keys[nextKey]] is T) {
          nextData[keys[nextKey]] = value;
          return;
        }

        if (nextData[keys[nextKey]] == null) {
          if (finish == true) {
            nextData[keys[nextKey]] = value;
            return;
          }

          nextData[keys[nextKey]] = {};
        }

        nextData = nextData[keys[nextKey]];
      }
    }
  }
}

/// Mixin class used to apply additional binding operations to every component
/// that supports it.
mixin BindingMixin {
  /// Parse schema object according to provided [key].
  Map<dynamic, dynamic> getSchemaObject(String key) {
    final NssConfig config = NssIoc().use(NssConfig);
    if (!config.markup.useSchemaValidations) {
      return null;
    }
    if (config.schema.containsKey(key.split('.').first)) {
      var schemaObject = config.schema[key.split('.').first]
              [key.replaceFirst(key.split('.').first + '.', '')] ??
          {};
      return schemaObject;
    }
    return null;
  }

  /// Fetch the text [String] bound value of the provided text display component [data] & validate it according the site schema.
  /// Schema validation is only available when "useSchemaValidations" is applied.
  BindingValue getBindingText(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isNullOrEmpty()) {
      return BindingValue(null);
    }
    // Check binding matches.
    final String bindingMatches = bindMatches(data.bind, 'string');
    if (bindingMatches != null) {
      return BindingValue.bindingError(data.bind, errorText: bindingMatches);
    }
    // Fetch value.
    final String value = bindings.getValue<String>(data.bind);
    return BindingValue(value.isEmpty ? null : value);
  }

  /// Fetch the boolean [bool] bound value of the provided selection component [data] & validate it according the site schema.
  /// Schema validation is only available when "useSchemaValidations" is applied.
  BindingValue getBindingBool(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isNullOrEmpty()) {
      return BindingValue(false);
    }
    // Check binding matches.
    final String bindingMatches = bindMatches(data.bind, 'boolean');
    if (bindingMatches != null) {
      return BindingValue.bindingError(data.bind, errorText: bindingMatches);
    }
    // Fetch value.
    var value = bindings.getValue<bool>(data.bind);
    return BindingValue(value);
  }

  /// Verify that bound value is exact.
  /// When useSchemaValidations is applied it is crucial to verifiy that the component "bind" markup field
  /// equals the correct schema field.
  String bindMatches(String key, String format) {
    final NssConfig config = NssIoc().use(NssConfig);
    // Validation only relevant when using schema valiation.
    if (!config.markup.useSchemaValidations) return null;

    // Schema may be null. If so move on.
    final schema = config.schema;
    if (schema == null) {
      return null;
    }

    if (schema.containsKey(key.split('.').first)) {
      final Map<dynamic, dynamic> schemaObject = getSchemaObject(key);

      // Verify binding field exists
      if (schemaObject.isEmpty) {
        engineLogger.e('Dev error: Binding key: $key does not exist in schema');
        return 'Dev error: Binding key: $key does not exist in schema';
      }

      // Verify binding field matches.
      if (schemaObject['type'] == 'string' && format != 'string') {
        engineLogger.e(
            'Dev error: binding key:$key is marked as String but provided with a non string UI component');
        return 'Dev error: binding key:$key is marked as String but provided with a non string UI component';
      }
      if (schemaObject['type'] == 'boolean' && format != 'boolean') {
        engineLogger.e(
            'Dev error: binding key:$key is marked as boolean but provided with a non boolean UI component');
        return 'Dev error: binding key:$key is marked as boolean but provided with a non boolean UI component';
      }
    }
    return null;
  }

  /// Get the correct keyboard display type [TextInputType] according to schema field type.
  TextInputType getBoundKeyboardType(String key) {
    final NssConfig config = NssIoc().use(NssConfig);
    // Validation only relevant when using schema valiation.
    if (!config.markup.useSchemaValidations) return TextInputType.text;

    final Map<dynamic, dynamic> schemaObject = getSchemaObject(key);
    if (schemaObject == null) return TextInputType.text;
    if (schemaObject.isEmpty) return TextInputType.text;

    final String type = schemaObject['type'] ?? 'string';
    switch (type) {
      case 'string':
        return TextInputType.text;
      case 'integer':
      case 'double':
      case 'number':
      case 'date':
        return TextInputType.number;
    }
    return TextInputType.text;
  }

  /// Display a non matching error for the provided binding markupl [key].
  Widget showBindingDoesNotMatchError(String key, {String errorText}) {
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

/// Helper class for fetching the bound data of a component.
class BindingValue {
  dynamic value;
  bool error = false;
  String errorText;

  BindingValue(value)
      : value = value,
        error = false;

  BindingValue.bindingError(value, {errorText})
      : value = value,
        error = true,
        errorText = errorText;
}
