import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Abstract platform aware [StatelessWidget] for Material & Cupertino.
abstract class NssPlatformWidget extends StatelessWidget {
  final isPlatformAware;

  NssPlatformWidget({
    Key key,
    @required this.isPlatformAware,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isPlatformAware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}

/// Abstract platform aware [StatefulWidget] state for Material & Cupertino.
abstract class NssPlatformState<T extends StatefulWidget> extends State<T> {
  final isPlatformAware;

  NssPlatformState({
    @required this.isPlatformAware,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlatformAware && Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }

  Widget buildCupertinoWidget(BuildContext context);

  Widget buildMaterialWidget(BuildContext context);
}
