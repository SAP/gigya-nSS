import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gigya_native_screensets_engine/main.dart';
import 'package:gigya_native_screensets_engine/relay/logger.dart';
import 'package:provider/provider.dart';

/// Main initialization business logic component.
class InitializationBloc {
  //TODO String result is currently used for this development stage.
  Future<Map<dynamic, dynamic>> initEngine() {
    return ChannelRegistry.mainChannel.invokeMethod<Map<dynamic, dynamic>>("engineInit");
  }

  Map<dynamic, dynamic> parseJsonData(json) {
    return null;
  }

  String loadMockJson() {
    return '';
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
  var useMockData = true;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<InitializationBloc>(context);
    return Container(
      child: FutureBuilder(
        future: provider.initEngine(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Logger.debugLog('', 'Initialization response: ${snapshot.data.toString()}');

            // Parsing the Json data.
            final String jsonData = useMockData ? provider.loadMockJson() : snapshot.data['json'];
            provider.parseJsonData(jsonData);

            // Building the AppWidget according to platform awareness.
            final platformAware = snapshot.data['platformAware'];
            return _createAppWidget(platformAware, widget.mainRoute);
          } else {
            return Container();
          }
        },
      ),
    );
  }

  /// Create main AppWidget according to initialization data.
  /// In case [platformAware] property is true, application will be determined via device platform.
  Widget _createAppWidget(platformAware, mainRoute) {
    // Currently ignoring platform awareness.
    if (platformAware && Platform.isIOS) {
      return NativeScreensCupertinoApp(mainRoute);
    }
    return NativeScreensMaterialApp(mainRoute);
  }
}

class NativeScreensMaterialApp extends MaterialApp {
  final MainRoute mainRoute;

  NativeScreensMaterialApp(this.mainRoute);

  @override
  Widget get home => mainRoute();
}

class NativeScreensCupertinoApp extends CupertinoApp {
  final MainRoute mainRoute;

  NativeScreensCupertinoApp(this.mainRoute);

  @override
  Widget get home => mainRoute();
}
