import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/main.dart';
import 'package:gigya_native_screensets_engine/relay/logger.dart';
import 'package:gigya_native_screensets_engine/utils/assets.dart';
import 'package:provider/provider.dart';

/// Main initialization business logic component. Temporary.
class InitializationBloc {

  final MethodChannel mainChannel = const MethodChannel('gigya_nss_engine/method/platform');

  //TODO String result is currently used for this development stage.
  Future<Map<dynamic, dynamic>> initEngine() {
    return mainChannel.invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }
}

typedef Widget MainRoute();

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class EngineInitializationWidget extends StatelessWidget {
  final MainRoute mainRoute;
  final bool useMockData;

  EngineInitializationWidget({Key key, @required this.mainRoute, this.useMockData = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _initEngine(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Logger.d('Initialization response: ${snapshot.data.toString()}');

            // Is this screen set platform aware?
            final platformAware = snapshot.data['platformAware'] ?? false;

            Logger.d('Using Cupertino platform for iOS: ${platformAware.toString()}');
            Logger.d('Markup String: ${snapshot.data['markup']}');

            // Parse markup and provide App widget.
            final Map<dynamic, dynamic> parsed = jsonDecode(snapshot.data['markup']);

            // Create application widget.
            return _createAppWidget(platformAware, mainRoute);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  /// Begin engine initialization process with requesting the data from the native library.
  Future<Map<dynamic, dynamic>> _initEngine() {
    return useMockData
        ? AssetUtils.jsonMapFromAssets('mock_1.json')
        : ChannelRegistry.mainChannel.invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }

  /// Create main AppWidget according to initialization data.
  /// In case [platformAware] property is true, application will be determined via device platform.
  Widget _createAppWidget(platformAware, mainRoute) {
    // Currently ignoring platform awareness.
    return MultiProvider(
        providers: [],
        child: (platformAware && Platform.isIOS)
            ? NativeScreensCupertinoApp(mainRoute)
            : NativeScreensMaterialApp(mainRoute));
  }
}

/// Customized MaterialApp widget for Android/Global devices.
class NativeScreensMaterialApp extends MaterialApp {
  final MainRoute mainRoute;

  NativeScreensMaterialApp(this.mainRoute);

  @override
  Widget get home => mainRoute();
}

/// Customized CupertinoApp for iOS devices.
class NativeScreensCupertinoApp extends CupertinoApp {
  final MainRoute mainRoute;

  NativeScreensCupertinoApp(this.mainRoute);

  @override
  Widget get home => mainRoute();
}
