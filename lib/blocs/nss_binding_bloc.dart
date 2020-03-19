import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';

/// Screen data binding model used for each [NssScreen]. Data is injected using the
/// flow initialization process from the native bridge.
class BindingModel with ChangeNotifier {
  final int _limit = 10;
  final regExp = new RegExp(r'^(.*)[[0-9]]$');

  Map<String, dynamic> bindingData = {};

  /// Update biding data once available. Updating the data will trigger rebuild for
  /// every child widget in the view tree.
  void updateWith(Map<String, dynamic> map) {
    bindingData = map;
    notifyListeners();
  }

  /// Get the relevant bound data using the String [key] reference.
  String getValue(String key) {
    var keys = key.split('.');
    var nextKey = 0;
    var nextData = bindingData[keys[nextKey]];
    dynamic value = '';

    if (keys.length >= _limit || nextData == null) {
      return 'key not found';
    }

    while (value.isEmpty) {
      if (nextData is String) {
        value = nextData;
      } else if (regExp.hasMatch(keys[nextKey])) {
        var arrayKeyData = keys[nextKey].split('[');
        var arrayKey = arrayKeyData[0];
        var arrayIndex = int.parse(arrayKeyData[1].replaceAll(']', ''));

        nextData = arrayIndex < (nextData[arrayKey] as List).length ? nextData[arrayKey][arrayIndex] : 'key not found';
        keys[nextKey] = arrayKey;
      } else {
        nextKey++;
        if (nextData[keys[nextKey]] != null) {
          nextData = nextData[keys[nextKey]];
        }
      }
    }

    return value;
  }

  save(String key, String value) {
    var keys = key.split('.');
    var nextKey = 0;

    if (bindingData[keys[nextKey]] == null) {
      bindingData[keys[nextKey]] = {};
    }

    var finish = false;

    if (keys.length == 1) {
      bindingData[key] = value;
      return;
    }

    var nextData = bindingData[keys[nextKey]];

    while (finish == false) {
      nextKey++;

      if (nextKey >= keys.length - 1) {
        finish = true;
      }

      if (nextData != null) {
        if (nextData[keys[nextKey]] is String) {
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
      return bindings.getValue(data.bind);
    }
    return data.textKey ?? '';
  }
}
