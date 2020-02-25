import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_ignition.dart';
import 'package:gigya_native_screensets_engine/nss_injector.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _registerDependencies();
    return NssIgnitionWidget(
      worker: IgnitionWorker(),
    );
  }
}

_registerDependencies() {
  NssInjector()
      .register(
        NssConfig,
        (inj) => NssConfig(isMock: true), // Don't forget to update remove this val when compiling the library!!.
      )
      .register(
        NssChannels,
        (inj) => NssChannels(),
      )
      .register(NssIgnitionWidget, (inj) {}, singleton: false);
}
