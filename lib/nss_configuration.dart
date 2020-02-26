import 'package:flutter/services.dart';

import 'models/main.dart';

class NssConfig {
  bool isMock = false;
  bool isPlatformAware = false;
  Main main;

  NssConfig({this.isMock, this.isPlatformAware, this.main});
}

class NssChannels {
  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/main');
  final MethodChannel apiChannel = const MethodChannel('gigya_nss_engine/method/api');
}
