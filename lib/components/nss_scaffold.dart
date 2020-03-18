import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/blocs/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/components/nss_progress.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:provider/provider.dart';

class NssScaffoldWidget extends NssPlatformWidget {
  final NssConfig config;
  final String appBarTitle;
  final Widget body;

  NssScaffoldWidget({
    @required this.config,
    @required this.appBarTitle,
    @required this.body,
  }) : super(isPlatformAware: config.isPlatformAware);

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
        leading:  Platform.isIOS ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, "dismiss"),
        ) : null,
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
        ? NssScreenProgressWidget(config: config)
        : Container();
  }
}