import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/registry.dart';
import 'package:gigya_native_screensets_engine/relay/logger.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:provider/provider.dart';

typedef Widget Layout(Map markup);

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class EngineInitializationWidget extends StatelessWidget {
  final Layout layout;
  final bool useMockData;

  EngineInitializationWidget(
      {Key key, @required this.layout, this.useMockData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _initEngine(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Logger.d('Initialization response: ${snapshot.data.toString()}');

            // Is this screen set platform aware?
            final platformAware = snapshot.data['platformAware'] ?? false;

            Logger.d(
                'Using Cupertino platform for iOS: ${platformAware.toString()}');
            Logger.d('Markup String: ${snapshot.data['markup']}');

            // Parse markup and provide App widget.
            var parsed = snapshot.data['markup'];

            // Create application widget.
            return _createAppWidget(
              platformAware,
              layout,
              parsed,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  /// Begin engine initialization process with requesting the data from the native library.
  Future<Map<String, dynamic>> _initEngine(context) {
    return useMockData
        ? AssetUtils.jsonMapFromAssets('assets/mock_1.json')
        : Provider.of<EngineRegistry>(context)
            .channels
            .mainChannel
            .invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }

  /// Create main AppWidget according to initialization data.
  /// In case [platformAware] property is true, application will be determined via device platform.
  Widget _createAppWidget(platformAware, layout, markup) {
    // Currently ignoring platform awareness.
    return (platformAware && Platform.isIOS)
        ? NativeScreensCupertinoApp(layout, markup)
        : NativeScreensMaterialApp(layout, markup);
  }
}

/// Customized MaterialApp widget for Android/Global devices.
class NativeScreensMaterialApp extends MaterialApp {
  final Layout layout;
  final Map markup;

  NativeScreensMaterialApp(this.layout, this.markup);

  @override
  Widget get home => layout(markup);
}

/// Customized CupertinoApp for iOS devices.
class NativeScreensCupertinoApp extends CupertinoApp {
  final Layout layout;
  final Map markup;

  NativeScreensCupertinoApp(this.layout, this.markup);

  @override
  Widget get home => layout(markup);
}
