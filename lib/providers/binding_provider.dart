import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/ioc/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';

enum BindingType { none, date }

/// Screen data binding model used for each [NssScreen]. Data is injected using the
/// flow initialization process from the native bridge.
class BindingModel with ChangeNotifier {
  final int _limit = 10;
  final regExp = new RegExp(r'^(.*)[[0-9]]$');

  // map of supported types with default return value.
  final typeSupported = {"String": '', "bool": false, "List<dynamic>": [], "dynamic": "", "int": 0};

  // default return when type not supported
  final defaultReturn = '';

  // Main widget binding date map.
  AsArrayHelper asArrayHelper = AsArrayHelper();

  Map<String, dynamic> _bindingData = {};

  // Binding data that is accumulated with new saved items.
  Map<String, dynamic> savedBindingData = {};

  // Additional routing data added via route events.
  Map<String, dynamic> _routingBindingData = {};

  // Keeping track of binding values and onChanged values.
  // Key = widget bind field.
  // Value = current value.
  Map<String, dynamic> _valueChangeData = {};

  /// Check if binding data is available for data fetch.
  bool bindingDataAvailable() {
    return _bindingData.isNotEmpty;
  }

  /// Check if dynamic [bind] field is of type [List] which will indicate that
  /// there are multiple bind fields for the requesting widget.
  bool isArrayTypeBinding(dynamic bind) {
    if (bind is List) return true;
    return false;
  }

  /// Check if dynamic [bind] field is of type [Map].
  /// Will indicate that we are binding to a concrete class.
  bool isObjectTypeBinding(dynamic bind) {
    if (bind is Map) return true;
    return false;
  }

  /// Check if dynamic [bind] field is of type [String].
  /// Simple String value bind.
  bool isStringTypeBinding(dynamic bind) {
    if (bind is String) return true;
    return false;
  }

  /// Update biding data once available. Updating the data will trigger rebuild for
  /// every child widget in the view tree.
  void updateWith(Map<String, dynamic> map) {
    _bindingData.addAll(map);
    notifyListeners();
  }

  void updateRoutingWith(Map<String, dynamic> map) {
    _routingBindingData.addAll(map);
    notifyListeners();
  }

  dynamic getSavedValue<T>(String key, [dynamic asArray]) {
    return getValue<T>(key, savedBindingData, asArray);
  }

  /// Get the relevant bound data using the String [key] reference.
  dynamic getValue<T>(String key, [Map<String, dynamic> dataObject, dynamic asArray]) {

    if (asArray != null) {
      return asArrayHelper.getValue(getValue(key), asArray, key);
    }

    // Remove `#` mark before submit.
    key = key.removeHashtagPrefix();

    var bindingData = dataObject ?? _routingBindingData;

    var keys = key.split('.');
    var nextKey = 0;
    var nextData = bindingData[keys[nextKey]];
    dynamic value;

    if (keys.length >= _limit || nextData == null) {
      if (dataObject != _bindingData) {
        var vv = getValue<T>(key, _bindingData);
        return vv;
      } else {
        return typeSupported[T.toString()] ?? defaultReturn;
      }
    }

    while (value == null) {
      if (typeSupported[nextData.runtimeType.toString()] != null) {
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
          if (dataObject != _bindingData) {
            var vv = getValue<T>(key, _bindingData);
            return vv ?? defaultReturn;
          } else {
            return typeSupported[T.toString()] ?? defaultReturn;
          }
        }

        if (nextData[keys[nextKey]] != null) {
          nextData = nextData[keys[nextKey]];
        }
      }
    }

    return value;
  }

  dynamic getMapByKey(String key) {
    return _bindingData[key];
  }

  /// Save a new [key] / [value] pair for form submission.
  save<T>(String key, T value, {String saveAs , dynamic asArray}) {
      if (key.isNullOrEmpty()) return;
      // Change the bind to real param before sending the request.
      if (saveAs != null && saveAs.isNotEmpty) key = saveAs;

      // Remove `#` mark before submit.
      final String checkedKey = key.removeHashtagPrefix();

      if (asArray != null) {
        List<dynamic> asArrayValue = asArrayHelper.getValueForSave(getValue(key), asArray, key, value);
        var keys = checkedKey.split('.');
        keys.removeLast();
        var k = keys.join('.');
        saveTo(k, asArrayValue, savedBindingData);
        saveTo(k, asArrayValue, _bindingData);

        saveTo(checkedKey, asArrayValue, savedBindingData);
        saveTo(checkedKey, asArrayValue, _bindingData);
      } else {
        saveTo(checkedKey, value, savedBindingData);
        saveTo(checkedKey, value, _bindingData);
      }
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
        if (nextData[keys[nextKey]] is T && nextData[keys[nextKey]] != null) {
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
  BindingValue getBindingText(NssWidgetData data, BindingModel bindings, {dynamic asArray}) {
    if (data.bind == null) {
      return BindingValue(null);
    }
    // Check binding matches.
    final String bindingMatches = bindMatches(data.bind, 'string');
    if (bindingMatches != null) {
      return BindingValue.bindingError(data.bind, errorText: bindingMatches);
    }
    // Fetch value.
    final String value = bindings.getValue<String>(data.bind, asArray);
    return BindingValue(value.isEmpty ? null : value);
  }

  /// Fetch the boolean [bool] bound value of the provided selection component [data] & validate it according the site schema.
  /// Schema validation is only available when "useSchemaValidations" is applied.
  BindingValue getBindingBool(NssWidgetData data, BindingModel bindings, {dynamic asArray}) {
    if (data.bind == null) {
      return BindingValue(false);
    }
    // Check binding matches.
    final String bindingMatches = bindMatches(data.bind, 'boolean');
    if (bindingMatches != null && asArray != null) {
      return BindingValue.bindingError(data.bind, errorText: bindingMatches);
    }
    // Fetch value.
    try {
      var value = bindings.getValue<bool>(data.bind, null, asArray);
      return BindingValue(value);
    } catch (e) {
      return BindingValue(false);
    }
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

class AsArrayHelper {
  dynamic getValue<T>(List<dynamic> data, dynamic asArray, String bindKey) {

    var keys = bindKey.split('.');
    var arrayDetails = asArray.cast<String, String>();
    for (dynamic obj in data) {
      if (obj[arrayDetails['key']] != null && obj[arrayDetails['key']] == arrayDetails['value']) {
        // return to "real" value.
        return obj[keys.last];
      }
    }

    return false;
  }

  dynamic getValueForSave<T>(List<dynamic> data, dynamic asArray, String bindKey, dynamic value) {
    var keys = bindKey.split('.');

    var arrayDetails = asArray.cast<String, String>();
    bool isExists = false;
    List<dynamic> tempData = [...data];

    for (dynamic obj in data) {
      if (obj[arrayDetails['key']] != null && obj[arrayDetails['key']] == arrayDetails['value']) {
        isExists = true;
        if (value == null || value == false) {
          tempData.remove(obj);
        } else
        if (value != obj[keys.last]) {
          tempData.remove(obj);
          isExists = false;
        }
      }
    }

    if (isExists == false) {
      tempData.add({arrayDetails['key']: arrayDetails['value'], keys.last: value});
    }

    return tempData;
  }
}
