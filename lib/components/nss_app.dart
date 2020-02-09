import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/utils/debug.dart';

typedef Widget Layout(Main main, String initialRoute);

class NssApp extends NssStatelessPlatformWidget {
  final Layout layout;
  final Main markup;
  final String initialRoute;
  final bool isMock;

  NssApp(this.layout, this.markup, this.initialRoute, this.isMock);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return buildMaterialWidget(context);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return MaterialApp(
      home: isMock
          ? Stack(
              children: <Widget>[
                layout(markup, initialRoute),
                NssDebugDecorWidget(),
              ],
            )
          : layout(markup, initialRoute),
    );
  }
}
