import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
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
    saveTo(key, value, savedBindingData);
    saveTo(key, value, _bindingData);
  }

  /// Update the binding data map with required [key] and [value].
  saveTo<T>(String key, T value, Map<String, dynamic> tmpData ) {
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
  String getText(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isAvailable()) {
      final String value = bindings.getValue<String>(data.bind);
      return value.isEmpty ? '' : value;
    }
    if (data.textKey.isAvailable()) {
      return data.textKey;
    }
    return '';
  }

  bool getBool(NssWidgetData data, BindingModel bindings) {
    if (data.bind.isAvailable()) {
      var value = bindings.getValue<bool>(data.bind);

      return value;
    }
    return false;
  }
}
