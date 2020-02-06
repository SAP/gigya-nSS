import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';

abstract class NssStatelessPlatformWidget extends StatelessWidget {
  NssStatelessPlatformWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool aware = registry.isPlatformAware ?? false;
    if (aware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}

abstract class NssStatefulPlatformWidgetState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    bool aware = registry.isPlatformAware ?? false;
    if (aware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}
