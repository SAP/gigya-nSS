import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/nss_router.dart';

class NssApp extends NssStatelessPlatformWidget {
  final Main markup;

  NssApp(this.markup);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return MaterialApp(
      initialRoute: markup.initialRoute,
      onGenerateRoute: Router(main: markup).generateRoute,
    );
  }
}
