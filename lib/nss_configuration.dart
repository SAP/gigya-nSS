import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/markup.dart';

/// Engine configuration class.
class NssConfig {
  bool isMock = false;
  bool isPlatformAware = false;
  Markup main;

  NssConfig({this.isMock, this.isPlatformAware, this.main});
}

/// Engine static communication channels.
class NssChannels {
  final MethodChannel ignitionChannel = const MethodChannel('gigya_nss_engine/method/ignition');
  final MethodChannel screenChannel = const MethodChannel('gigya_nss_engine/method/screen');
  final MethodChannel apiChannel = const MethodChannel('gigya_nss_engine/method/api');
  final MethodChannel logChannel = const MethodChannel('gigya_nss_engine/method/log');
}

enum IgnitionChannelAction { ignition, ready_for_display }

extension IgnitionChannelActionExt on IgnitionChannelAction {
  String get action {
    return describeEnum(this);
  }
}

enum ScreenChannelAction { flow, submit }

extension ScreenChannelActionExt on ScreenChannelAction {
  String get action {
    return describeEnum(this);
  }
}
