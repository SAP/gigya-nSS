import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NssRegistryBloc {
  NssChannelRegistry _channelRegistry;

  NssChannelRegistry get channels {
    if (_channelRegistry == null) _channelRegistry = NssChannelRegistry();
    return _channelRegistry;
  }

  bool isPlatformAware = false;
}

class NssChannelRegistry {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
}

/// Engine actions.
enum NssAction { ignition }

extension NssActionExtension on NssAction {
  String get action {
    return describeEnum(this);
  }
}
