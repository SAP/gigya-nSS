import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/models/main.dart';
import 'package:gigya_native_screensets_engine/registry.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:provider/provider.dart';

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class EngineInitializationWidget extends StatelessWidget {
  final Layout layoutScreenSet;
  final bool useMockData;

  EngineInitializationWidget({Key key, @required this.layoutScreenSet, this.useMockData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: initEngine(context),
        builder: (context, AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
          if (snapshot.hasData) {
            debugPrint('Init engine has data');

            // Is this screen set platform aware?
            final platformAware = snapshot.data['platformAware'] ?? false;

            debugPrint('Using Cupertino platform for iOS: ${platformAware.toString()}');

            // Parse markup and provide App widget.
            Main parsed = Main.fromJson(snapshot.data['markup'].cast<String, dynamic>());

            debugPrint('Markup String: $parsed');

            // Create application widget.
            return createAppWidget(
              platformAware,
              layoutScreenSet,
              parsed,
            );
          } else {
            return Container(
              color: Color(0xFFFFFFFF),
            );
          }
        },
      ),
    );
  }

  /// Begin engine initialization process with requesting the data from the native library.
  Future<Map<dynamic, dynamic>> initEngine(context) {
    return useMockData
        ? AssetUtils.jsonMapFromAssets('assets/mock_1.json')
        : getRegistry(context)
            .channels
            .mainChannel
            .invokeMethod<Map<dynamic, dynamic>>(MainAction.initialize.action);
  }

  @visibleForTesting
  EngineRegistry getRegistry(context) {
    return Provider.of<EngineRegistry>(context);
  }

  /// Create main AppWidget according to initialization data.
  /// In case [platformAware] property is true, application will be determined via device platform.
  Widget createAppWidget(platformAware, layout, markup) {
    // Currently ignoring platform awareness.
    return (platformAware && Platform.isIOS)
        ? NativeScreensCupertinoApp(layout, markup)
        : NativeScreensMaterialApp(layout, markup);
  }
}

typedef Widget Layout(Main main);

/// Customized MaterialApp widget for Android/Global devices.
class NativeScreensMaterialApp extends MaterialApp {
  final Layout layout;
  final Main markup;

  NativeScreensMaterialApp(this.layout, this.markup);

  @override
  Widget get home => layout(markup);
}

/// Customized CupertinoApp for iOS devices.
class NativeScreensCupertinoApp extends CupertinoApp {
  final Layout layout;
  final Main markup;

  NativeScreensCupertinoApp(this.layout, this.markup);

  @override
  Widget get home => layout(markup);
}
