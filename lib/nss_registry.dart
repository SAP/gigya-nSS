import 'package:flutter/services.dart';

class NssRegistry {
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

// Global access.
NssRegistry registry = NssRegistry();
