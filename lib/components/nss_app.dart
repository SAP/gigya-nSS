import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';

class NssApp extends NssPlatformWidget {
  // Config instance is a singleton. Therefore it is available for binding.
  final NssConfig config;
  final Router router;

  NssApp({
    @required this.config,
    @required this.router,
  }) : super(isPlatformAware: config.isPlatformAware);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      initialRoute: config.main.initialRoute,
      onGenerateRoute: router.generateRoute,
    );
  }
}
