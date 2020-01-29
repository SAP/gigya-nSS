import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NssRegistryBloc {
  final channels = NssChannelRegistry();
}

class NssChannelRegistry {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
}

/// Engine actions enum.
enum NssAction { ignition }

extension NssActionExtension on NssAction {
  String get action {
    return describeEnum(this);
  }
}
