import 'package:flutter/services.dart';

class NssConfig {
  bool isMock = false;
  bool isPlatformAware = false;

  NssConfig({this.isMock, this.isPlatformAware});
}

class NssChannels {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
  final MethodChannel apiChannel = const MethodChannel('gigya_nss_engine/method/api');
}
