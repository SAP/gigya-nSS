import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NssRegistryBloc {
  NssChannelRegistry _channelRegistry;

  NssChannelRegistry get channels {
    if (_channelRegistry == null) _channelRegistry = NssChannelRegistry();
    return _channelRegistry;
  }

  NssFormRegistry _formRegistry;

  NssFormRegistry get forms {
    if (_formRegistry == null) _formRegistry = NssFormRegistry();
    return _formRegistry;
  }
}

class NssChannelRegistry {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
}

class NssFormRegistry {
  final Map<String, GlobalKey<FormState>> keyMap = {};

  GlobalKey<FormState> formKeyFor(id) {
    return keyMap[id];
  }

  addFormKey(id, key) {
    keyMap[id] = key;
  }

  remove(id) {
    keyMap.remove(id);
  }

  flush() {
    keyMap.clear();
  }
}

/// Engine actions enum.
enum NssAction { ignition }

extension NssActionExtension on NssAction {
  String get action {
    return describeEnum(this);
  }
}
