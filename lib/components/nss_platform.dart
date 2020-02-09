import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/nss_registry.dart';

//TODO: Not sure that we need the [Platform.isIOS] check for all platform widgets.

/// Abstract platform aware [StatelessWidget] for Material & Cupertino.
abstract class NssStatelessPlatformWidget extends StatelessWidget {
  NssStatelessPlatformWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool aware = registry.isPlatformAware;
    if (aware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}

/// Abstract platform aware [StatefulWidget] state for Material & Cupertino.
abstract class NssStatefulPlatformWidgetState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    bool aware = registry.isPlatformAware;
    if (aware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}
