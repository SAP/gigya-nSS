import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/providers/nss_screen_bloc.dart';
import 'package:gigya_native_screensets_engine/components/nss_errors.dart';
import 'package:gigya_native_screensets_engine/components/nss_platform.dart';
import 'package:gigya_native_screensets_engine/components/nss_progress.dart';
import 'package:gigya_native_screensets_engine/nss_configuration.dart';
import 'package:provider/provider.dart';

/// Screen navigation bar data used to build the [AppBar] for Material style
/// or [CupertinoNavigationBar] for Cupertino.
class NssAppBarData {
  final String title;

  NssAppBarData(this.title);
}

/// Screen main scaffold widget.
class NssScaffoldWidget extends NssPlatformWidget {
  final NssConfig config;
  final NssAppBarData appBarData;
  final Widget screenBody;

  NssScaffoldWidget({
    @required this.config,
    @required this.appBarData,
    @required this.screenBody,
  }) : super(isPlatformAware: config.isPlatformAware);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    // TODO: implement buildCupertinoWidget
    return Container();
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: _buildMaterialAppBar(context),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            screenBody,
            NssFormErrorWidget(),
            _displayActivityIndication(context),
          ],
        ),
      ),
    );
  }

  /// Build Material design [AppBar] widget according to provided [NssWidgetData] parameters.
  AppBar _buildMaterialAppBar(context) {
    if (appBarData != null) {
      return AppBar(
        title: Text(appBarData.title),
        leading: Platform.isIOS
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, "dismiss"),
              )
            : null,
      );
    }
    return null;
  }

  /// According to screen state handled by the [NssScreenViewModel] activity indication should be displayed
  /// on top of the screen content.
  Widget _displayActivityIndication(context) {
    var viewModel = Provider.of<NssScreenViewModel>(context);
    return viewModel.isProgress() ? NssScreenProgressWidget(config: config) : Container();
  }
}
