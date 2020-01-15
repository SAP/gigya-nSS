import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/main.dart';
import 'package:gigya_native_screensets_engine/relay/logger.dart';
import 'package:gigya_native_screensets_engine/util/assets.dart';
import 'package:provider/provider.dart';

/// Main initialization business logic component. Temporary.
class InitializationBloc {
  //TODO String result is currently used for this development stage.
  Future<Map<dynamic, dynamic>> initEngine() {
    return ChannelRegistry.mainChannel.invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }
}

typedef Widget MainRoute();

/// Engine initialization root widget.
/// The Main purpose of this widget is to open a channel to the native code in order to obtain all
/// the necessary initialization data/configuration and determine the actual theme of the main app along
/// with obtaining & parsing the main JSON data.
class EngineInitializationWidget extends StatefulWidget {
  final MainRoute mainRoute;

  const EngineInitializationWidget({Key key, this.mainRoute}) : super(key: key);

  @override
  _EngineInitializationWidgetState createState() => _EngineInitializationWidgetState();
}

class _EngineInitializationWidgetState extends State<EngineInitializationWidget> {
  var useMockData = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _initEngine(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Logger.debugLog('', 'Initialization response: ${snapshot.data.toString()}');

            // Is this screen set platform aware?
            final platformAware = snapshot.data['platformAware'] ?? false;

            Logger.debugLog('EngineInitializationWidget',
                'Using Cupertino platform for iOS: ${platformAware.toString()}');
            Logger.debugLog(
                'EngineInitializationWidget', 'Markup String: ${snapshot.data['markup']}');

            // Parse markup and provide App widget.
            return FutureBuilder(
                future: _parseMarkup(snapshot.data['markup']),
                builder: (context, snapshot) {
                  Logger.debugLog(
                      'EngineInitializationWidget', 'Parsed markup: ${snapshot.data.toString()}');

                  if (snapshot.hasData) {
                    // Successfully loaded & parsed markup data.
                    return _createAppWidget(platformAware, widget.mainRoute);
                  } else {
                    return Container();
                  }
                });
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

  /// Parse markup json to a dynamic map.
  Future<Map<dynamic, dynamic>> _parseMarkup(snapshot) async {
    return jsonDecode(snapshot);
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
