import 'package:flutter/services.dart';

class EngineRegistry {
  final channels = ChannelRegistry();
}

class ChannelRegistry {
  final MethodChannel mainChannel =
      const MethodChannel('gigya_nss_engine/method/platform');
}
