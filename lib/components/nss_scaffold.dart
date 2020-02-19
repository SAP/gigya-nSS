import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/components/nss_progress.dart';
import 'package:provider/provider.dart';

class NssScaffoldWidget extends NssStatelessPlatformWidget {
  final String appBarTitle;
  final Widget body;

  NssScaffoldWidget({this.appBarTitle, this.body});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return Container();
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            body,
            NssFormErrorWidget(),
            activityIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget activityIndicator(context) {
    return Provider.of<NssScreenViewModel>(context).isProgress()
        ? NssScreenProgressWidget()
        : Container();
  }
}
