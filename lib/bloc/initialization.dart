import 'package:flutter/services.dart';

class InitializationBloc {
  static const mainComm =
      const MethodChannel('gigya_nss_engine/method/platform');

  //TODO String result is currently used for this development stage.
  Future<Map<dynamic, dynamic>> initEngine() {
    return mainComm.invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }

  void parseInitializationData() {}
}
