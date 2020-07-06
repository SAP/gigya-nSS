import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/config.dart';
import 'package:gigya_native_screensets_engine/injector.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

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

        nextData = arrayIndex < (nextData[arrayKey] as List).length ? nextData[arrayKey][arrayIndex] : '';
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

  save<T>(String key, T value) {
    // Remove `#` mark before submit.
    key.removeHashtagPrefix();

    saveTo(key, value, savedBindingData);
    saveTo(key, value, _bindingData);
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

mixin BindingMixin {
  BindingValue getBindingText(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isAvailable()) {
      final String value = bindings.getValue<String>(data.bind);
      if (!schemaBindFieldValidated(data.bind, value)) {
        return BindingValue.bindingError(data.bind);
      }
      return BindingValue(value.isEmpty ? null : value);
    }
    return BindingValue(null);
  }

  BindingValue getBindingBool(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isAvailable()) {
      var value = bindings.getValue<bool>(data.bind);
      if (!schemaBindFieldValidated(data.bind, value)) {
        return BindingValue.bindingError(data.bind);
      }
      return BindingValue(value);
    }
    return BindingValue(false);
  }

  bool schemaBindFieldValidated(String key, dynamic value) {
    final NssConfig config = NssIoc().use(NssConfig);
    if (!config.markup.useSchemaValidations) return true;

    final schema = config.schema;
    if (schema == null) {
      engineLogger.d('Schema still not available', tag: 'NssEngine');
      return true;
    } else {
      engineLogger.d('Schema available', tag: 'NssEngine');
    }

    if (schema.containsKey(key.split('.').first)) {
      final Map<dynamic, dynamic> schemaObject =
          schema[key.split('.').first][key.replaceFirst(key.split('.').first + '.', '')] ?? {};
      if (schemaObject.isEmpty) {
        engineLogger.d('Binding key:$key is not aligned with schema field. Verify markup.');
        return false;
      }
      if (schemaObject['type'] == 'string' && value is! String) {
        engineLogger.d('Binding key:$key is not aligned with schema field. Verify markup.');
        return false;
      }
      if (schemaObject['type'] == "number" && (value is! num)) {
        engineLogger.d('Binding key:$key is not aligned with schema field. Verify markup.');
        return false;
      }
      if (schemaObject['type'] == "boolean" && value is! bool) {
        engineLogger.d('Binding key:$key is not aligned with schema field. Verify markup.');
        return false;
      }
    }
    return true;
  }

  Widget showBindingError(String key) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          'Binding key:$key is not aligned with schema field. Verify markup.',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}

class BindingValue {
  dynamic value;
  bool error = false;

  BindingValue(value)
      : value = value,
        error = false;

  BindingValue.bindingError(value)
      : value = value,
        error = true;
}
