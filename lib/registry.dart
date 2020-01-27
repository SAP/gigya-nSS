import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class EngineRegistry {
  final channels = ChannelRegistry();
}

class ChannelRegistry {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
}

/// Main channel actions.
enum MainAction { initialize }

extension MainActionExtension on MainAction {

  String get action {
    return describeEnum(this);
  }
}
