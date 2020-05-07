import 'package:flutter/services.dart';
import 'package:gigya_native_screensets_engine/models/markup.dart';

class NssConfig {
  bool isMock = false;
  bool isPlatformAware = false;
  Markup markup;

  NssConfig({this.isMock, this.isPlatformAware, this.markup});
}

class NssChannels {
  final MethodChannel ignitionChannel = const MethodChannel('gigya_nss_engine/method/ignition');
  final MethodChannel screenChannel = const MethodChannel('gigya_nss_engine/method/screen');
  final MethodChannel apiChannel = const MethodChannel('gigya_nss_engine/method/api');
  final MethodChannel logChannel = const MethodChannel('gigya_nss_engine/method/log');
}