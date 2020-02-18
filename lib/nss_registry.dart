import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NssRegistry {
  bool isPlatformAware = false;

  bool isMock = false;

  NssChannelRegistry _channelRegistry;

  NssChannelRegistry get channels {
    if (_channelRegistry == null) _channelRegistry = NssChannelRegistry();
    return _channelRegistry;
  }
}

class NssChannelRegistry {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');

  final MethodChannel apiChannel = const MethodChannel('gigya_nss_engine/method/api');
}

/// Engine main actions.
enum NssMainAction { ignition }

extension NssMainActionExtension on NssMainAction {
  String get action {
    return describeEnum(this);
  }
}

// Global access.
NssRegistry registry = NssRegistry();
