

import 'package:flutter/services.dart';

class InitializationBloc {

  static const mainComm = const MethodChannel('gigya_nss_engine/method/platform');

  Future<String> initEngine() {
    return mainComm.invokeMethod<String>("engineInit");
  }

}