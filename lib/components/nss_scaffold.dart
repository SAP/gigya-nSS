import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_state_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:provider/provider.dart';

class NssScaffoldWidget extends NssStatelessPlatformWidget {
  final String appBarTitle;
  final Widget child;

  NssScaffoldWidget({ this.appBarTitle, this.child});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return Container();
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    // TODO: implement buildMaterialWidget
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            child,
            NssFormErrorWidget(),
          ],
        ),
      ),
    );
  }
}


